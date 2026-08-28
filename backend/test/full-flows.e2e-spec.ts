import { randomUUID } from 'node:crypto';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import cookieParser from 'cookie-parser';
import request, { Response } from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { DomainExceptionFilter } from '../src/shared/infrastructure/http/domain-exception.filter';
import { PrismaService } from '../src/shared/infrastructure/prisma/prisma.service';

const SOLLANA_ID = '11111111-1111-4111-8111-111111111111';
const MANAGER_EMAIL = 'gestor@sollana.poblex.es';
const MANAGER_PASSWORD = 'CambiaEstaContrasena123';

function jsonBody<T>(response: Response): T {
  return response.body as T;
}

describe('Complete backend flows (e2e)', () => {
  let app: INestApplication<App>;
  let server: App;
  let prisma: PrismaService;
  let accessToken = '';
  let refreshCookie: string[] = [];

  const deviceId = randomUUID();
  const otherDeviceId = randomUUID();
  const throttledDeviceId = randomUUID();
  let createdFacilityId = '';
  const forbiddenMunicipalityId = randomUUID();
  const forbiddenSlug = `forbidden-${forbiddenMunicipalityId.slice(0, 8)}`;

  const authorization = (): { Authorization: string } => ({
    Authorization: `Bearer ${accessToken}`,
  });

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('v1');
    app.useGlobalPipes(
      new ValidationPipe({ whitelist: true, transform: true }),
    );
    app.useGlobalFilters(new DomainExceptionFilter());
    app.use(cookieParser());
    await app.init();

    server = app.getHttpServer();
    prisma = app.get(PrismaService);
    await prisma.municipality.create({
      data: {
        id: forbiddenMunicipalityId,
        slug: forbiddenSlug,
        name: 'Municipio no autorizado e2e',
        province: 'Valencia',
        primaryColor: '#8A461E',
        languages: ['es'],
        active: true,
      },
    });
  });

  afterAll(async () => {
    if (createdFacilityId) {
      await prisma.facility.deleteMany({ where: { id: createdFacilityId } });
    }
    await prisma.incident.deleteMany({
      where: { deviceId: { in: [deviceId, otherDeviceId, throttledDeviceId] } },
    });
    await prisma.device.deleteMany({
      where: { id: { in: [deviceId, otherDeviceId, throttledDeviceId] } },
    });
    await prisma.municipality.deleteMany({
      where: { id: forbiddenMunicipalityId },
    });
    await app.close();
  });

  it('checks health, authentication, refresh cookie and manager profile', async () => {
    await request(server)
      .get('/v1/health')
      .expect(200)
      .expect((response) => {
        expect(jsonBody<{ status: string }>(response).status).toBe('ok');
      });

    await request(server).get('/v1/health/aemet').expect(200);

    await request(server)
      .post('/v1/admin/auth/login')
      .send({ email: MANAGER_EMAIL, password: 'wrong-password' })
      .expect(401);

    const login = await request(server)
      .post('/v1/admin/auth/login')
      .send({ email: MANAGER_EMAIL, password: MANAGER_PASSWORD })
      .expect(201);

    accessToken = jsonBody<{ accessToken: string }>(login).accessToken;
    refreshCookie = login.headers['set-cookie'] as unknown as string[];
    expect(accessToken).not.toHaveLength(0);
    expect(refreshCookie.join(';')).toContain('poblex_refresh_token=');

    const refresh = await request(server)
      .post('/v1/admin/auth/refresh')
      .set('Cookie', refreshCookie)
      .expect(201);
    accessToken = jsonBody<{ accessToken: string }>(refresh).accessToken;
    refreshCookie = refresh.headers['set-cookie'] as unknown as string[];

    const concurrentRefreshes = await Promise.all([
      request(server)
        .post('/v1/admin/auth/refresh')
        .set('Cookie', refreshCookie),
      request(server)
        .post('/v1/admin/auth/refresh')
        .set('Cookie', refreshCookie),
    ]);
    expect(concurrentRefreshes.map(({ status }) => status).sort()).toEqual([
      201, 401,
    ]);
    const successfulRefresh = concurrentRefreshes.find(
      ({ status }) => status === 201,
    )!;
    accessToken = jsonBody<{ accessToken: string }>(
      successfulRefresh,
    ).accessToken;
    refreshCookie = successfulRefresh.headers[
      'set-cookie'
    ] as unknown as string[];

    await request(server)
      .get('/v1/admin/me')
      .set(authorization())
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{
          email: string;
          municipalities: Array<{ id: string; slug: string }>;
        }>(response);
        expect(body.email).toBe(MANAGER_EMAIL);
        expect(body.municipalities).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ id: SOLLANA_ID, slug: 'sollana' }),
          ]),
        );
      });

    await request(server)
      .post('/v1/admin/auth/forgot-password')
      .send({ email: 'unknown@example.test' })
      .expect(201)
      .expect({ accepted: true });
  });

  it('rejects malformed query values before they reach persistence', async () => {
    await request(server)
      .get('/v1/news')
      .query({ municipalityId: SOLLANA_ID, cursor: 'not-a-cursor' })
      .expect(400);

    await request(server)
      .get('/v1/admin/news')
      .set(authorization())
      .query({ municipalityId: SOLLANA_ID, includeArchived: 'not-a-boolean' })
      .expect(400);

    await request(server)
      .post('/v1/admin/news')
      .set(authorization())
      .send({
        municipalityIds: [SOLLANA_ID, SOLLANA_ID],
        title: { es: 'Duplicada' },
        body: { es: 'No debe publicarse dos veces' },
        category: 'pruebas-e2e',
      })
      .expect(400);
  });

  it('registers a device and updates its push registration', async () => {
    await request(server)
      .post('/v1/devices')
      .send({ municipalityId: SOLLANA_ID, locale: 'es' })
      .expect(400);

    await request(server)
      .post('/v1/devices')
      .set('X-Device-Id', deviceId)
      .send({
        municipalityId: SOLLANA_ID,
        locale: 'es',
        fcmToken: 'e2e-fake-token',
      })
      .expect(201)
      .expect((response) => {
        const body = jsonBody<{ id: string; municipalityId: string }>(response);
        expect(body.id).toBe(deviceId);
        expect(body.municipalityId).toBe(SOLLANA_ID);
      });

    await request(server)
      .patch(`/v1/devices/${deviceId}/push`)
      .set('X-Device-Id', otherDeviceId)
      .send({ locale: 'va' })
      .expect(400);

    await request(server)
      .patch(`/v1/devices/${deviceId}/push`)
      .set('X-Device-Id', deviceId)
      .send({ locale: 'va', fcmToken: null })
      .expect(200)
      .expect((response) => {
        expect(jsonBody<{ locale: string }>(response).locale).toBe('va');
      });

    await request(server)
      .post('/v1/devices')
      .set('X-Device-Id', otherDeviceId)
      .send({ municipalityId: SOLLANA_ID, locale: 'es' })
      .expect(201);

    await request(server)
      .post('/v1/devices')
      .set('X-Device-Id', throttledDeviceId)
      .send({ municipalityId: SOLLANA_ID, locale: 'es' })
      .expect(201);
  });

  it('limits incident reports to five per device and hour', async () => {
    for (let index = 0; index < 5; index += 1) {
      await request(server)
        .post('/v1/incidents')
        .set('X-Device-Id', throttledDeviceId)
        .send({
          municipalityId: SOLLANA_ID,
          category: 'pruebas-e2e',
          description: `Incidencia limitada ${index}`,
        })
        .expect(201);
    }

    await request(server)
      .post('/v1/incidents')
      .set('X-Device-Id', throttledDeviceId)
      .send({
        municipalityId: SOLLANA_ID,
        category: 'pruebas-e2e',
        description: 'Esta incidencia debe quedar limitada',
      })
      .expect(429);
  });

  it('enforces manager municipality isolation and completes the news CRUD', async () => {
    const payload = {
      municipalityIds: [SOLLANA_ID],
      title: { es: 'Noticia e2e', va: 'Notícia e2e' },
      body: { es: 'Contenido de prueba e2e', va: 'Contingut de prova e2e' },
      category: 'pruebas-e2e',
      imageUrl: 'https://cdn.example.test/news/e2e.webp',
      pinned: false,
    };

    await request(server).post('/v1/admin/news').send(payload).expect(401);

    await request(server)
      .post('/v1/admin/news')
      .set(authorization())
      .send({ ...payload, municipalityIds: [forbiddenMunicipalityId] })
      .expect(403);

    const created = await request(server)
      .post('/v1/admin/news')
      .set(authorization())
      .send(payload)
      .expect(201);
    const newsId = jsonBody<Array<{ id: string }>>(created)[0].id;

    await request(server)
      .get('/v1/news')
      .query({ municipalityId: SOLLANA_ID })
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ items: Array<{ id: string }> }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([expect.objectContaining({ id: newsId })]),
        );
      });

    await request(server)
      .patch(`/v1/admin/news/${newsId}`)
      .set(authorization())
      .send({ title: { es: 'Noticia e2e actualizada' } })
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{
          title: { es: string };
          imageUrl: string | null;
        }>(response);
        expect(body.title.es).toBe('Noticia e2e actualizada');
        expect(body.imageUrl).toBe(payload.imageUrl);
      });

    await request(server)
      .patch(`/v1/admin/news/${newsId}`)
      .set(authorization())
      .send({ imageUrl: null })
      .expect(200)
      .expect((response) => {
        expect(jsonBody<{ imageUrl: string | null }>(response).imageUrl).toBe(
          null,
        );
      });

    await request(server)
      .patch(`/v1/admin/news/${newsId}/pin`)
      .set(authorization())
      .send({ pinned: true })
      .expect(200)
      .expect((response) =>
        expect(jsonBody<{ pinned: boolean }>(response).pinned).toBe(true),
      );

    await request(server)
      .patch(`/v1/admin/news/${newsId}/archived`)
      .set(authorization())
      .send({ archived: true })
      .expect(200);

    await request(server)
      .get(`/v1/news/${newsId}`)
      .query({ municipalityId: SOLLANA_ID })
      .expect(404);

    await request(server)
      .get('/v1/admin/news')
      .set(authorization())
      .query({ municipalityId: SOLLANA_ID, includeArchived: true })
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{
          items: Array<{ id: string; archived: boolean }>;
        }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ id: newsId, archived: true }),
          ]),
        );
      });

    await request(server)
      .delete(`/v1/admin/news/${newsId}`)
      .set(authorization())
      .expect(204);
  });

  it('creates an event, manages a device reminder and deletes the event', async () => {
    await request(server)
      .get('/v1/admin/events')
      .set(authorization())
      .query({ municipalityId: forbiddenMunicipalityId })
      .expect(403);

    const startAt = new Date(Date.now() + 2 * 86_400_000);
    const created = await request(server)
      .post('/v1/admin/events')
      .set(authorization())
      .send({
        municipalityIds: [SOLLANA_ID],
        title: { es: 'Evento e2e' },
        description: { es: 'Descripción del evento e2e' },
        startAt: startAt.toISOString(),
        category: 'pruebas-e2e',
      })
      .expect(201);
    const eventId = jsonBody<Array<{ id: string }>>(created)[0].id;

    await request(server)
      .get('/v1/events')
      .query({ municipalityId: SOLLANA_ID })
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ items: Array<{ id: string }> }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([expect.objectContaining({ id: eventId })]),
        );
      });

    await request(server)
      .post(`/v1/events/${eventId}/reminder`)
      .set('X-Device-Id', deviceId)
      .send({
        remindAt: new Date(startAt.getTime() - 86_400_000).toISOString(),
      })
      .expect(201)
      .expect((response) =>
        expect(jsonBody<{ eventId: string }>(response).eventId).toBe(eventId),
      );

    await request(server)
      .delete(`/v1/events/${eventId}/reminder`)
      .set('X-Device-Id', deviceId)
      .expect(204);

    await request(server)
      .delete(`/v1/admin/events/${eventId}`)
      .set(authorization())
      .expect(204);
  });

  it('creates, publishes, updates and deletes a manual alert', async () => {
    const created = await request(server)
      .post('/v1/admin/alerts')
      .set(authorization())
      .send({
        municipalityId: SOLLANA_ID,
        severity: 'amarillo',
        phenomenonType: 'meteorologico',
        phenomenon: 'Prueba e2e',
        body: { es: 'Aviso de prueba e2e' },
        startAt: new Date(Date.now() - 60_000).toISOString(),
        endAt: new Date(Date.now() + 86_400_000).toISOString(),
      })
      .expect(201);
    const alertId = jsonBody<{ id: string }>(created).id;

    await request(server)
      .get('/v1/alerts')
      .query({ municipalityId: SOLLANA_ID })
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ items: Array<{ id: string }> }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([expect.objectContaining({ id: alertId })]),
        );
      });

    await request(server)
      .patch(`/v1/admin/alerts/${alertId}`)
      .set(authorization())
      .send({ severity: 'naranja' })
      .expect(200)
      .expect((response) =>
        expect(jsonBody<{ severity: string }>(response).severity).toBe(
          'naranja',
        ),
      );

    await request(server)
      .delete(`/v1/admin/alerts/${alertId}`)
      .set(authorization())
      .expect(204);
  });

  it('books, double-books and cancels a facility reservation', async () => {
    const created = await request(server)
      .post('/v1/admin/facilities')
      .set(authorization())
      .send({
        municipalityId: SOLLANA_ID,
        name: { es: 'Pista de pádel e2e' },
        category: 'Pádel',
        slotDurationMinutes: 60,
        openingHours: {
          mon: { open: '00:00', close: '23:59' },
          tue: { open: '00:00', close: '23:59' },
          wed: { open: '00:00', close: '23:59' },
          thu: { open: '00:00', close: '23:59' },
          fri: { open: '00:00', close: '23:59' },
          sat: { open: '00:00', close: '23:59' },
          sun: { open: '00:00', close: '23:59' },
        },
        maxAdvanceBookingDays: 30,
      })
      .expect(201);
    const facilityId = jsonBody<{ id: string }>(created).id;
    createdFacilityId = facilityId;

    await request(server)
      .get('/v1/facilities')
      .query({ municipalityId: SOLLANA_ID })
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ items: Array<{ id: string }> }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ id: facilityId }),
          ]),
        );
      });

    await request(server)
      .get(`/v1/facilities/${facilityId}`)
      .expect(200)
      .expect((response) => {
        expect(jsonBody<{ id: string }>(response).id).toBe(facilityId);
      });

    // Ventana amplia: "mañana" evita el flake de un hueco que caduque
    // mientras corre la suite, sin acoplarse a la hora exacta de ejecución.
    const tomorrow = new Date(Date.now() + 86_400_000);
    const tomorrowDate = tomorrow.toISOString().slice(0, 10);

    const availability = await request(server)
      .get(`/v1/facilities/${facilityId}/availability`)
      .query({ date: tomorrowDate })
      .expect(200);
    const slots = jsonBody<{ slots: Array<{ start: string }> }>(
      availability,
    ).slots;
    expect(slots.length).toBeGreaterThan(0);
    const slotStart = slots[0].start;

    const reservation = await request(server)
      .post('/v1/reservations')
      .set('X-Device-Id', deviceId)
      .send({ facilityId, slotStart })
      .expect(201);
    const reservationId = jsonBody<{ id: string }>(reservation).id;

    await request(server)
      .post('/v1/reservations')
      .set('X-Device-Id', otherDeviceId)
      .send({ facilityId, slotStart })
      .expect(409);

    await request(server)
      .get('/v1/reservations')
      .set('X-Device-Id', deviceId)
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ items: Array<{ id: string }> }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ id: reservationId }),
          ]),
        );
      });

    await request(server)
      .post(`/v1/reservations/${reservationId}/cancel`)
      .set('X-Device-Id', otherDeviceId)
      .expect(403);

    await request(server)
      .post(`/v1/reservations/${reservationId}/cancel`)
      .set('X-Device-Id', deviceId)
      .expect(201)
      .expect({ cancelled: true });

    const freedAvailability = await request(server)
      .get(`/v1/facilities/${facilityId}/availability`)
      .query({ date: tomorrowDate })
      .expect(200);
    expect(
      jsonBody<{ slots: Array<{ start: string }> }>(
        freedAvailability,
      ).slots.map((slot) => slot.start),
    ).toEqual(expect.arrayContaining([slotStart]));

    // Segunda reserva para probar la cancelación por gestor (exige nota y
    // dispara push dirigido al dispositivo, no por topic).
    const secondReservation = await request(server)
      .post('/v1/reservations')
      .set('X-Device-Id', deviceId)
      .send({ facilityId, slotStart })
      .expect(201);
    const secondReservationId = jsonBody<{ id: string }>(
      secondReservation,
    ).id;

    await request(server)
      .post(`/v1/admin/reservations/${secondReservationId}/cancel`)
      .set(authorization())
      .send({})
      .expect(400);

    await request(server)
      .post(`/v1/admin/reservations/${secondReservationId}/cancel`)
      .set(authorization())
      .send({ note: 'Pista en mantenimiento' })
      .expect(201)
      .expect({ cancelled: true });

    await request(server)
      .get('/v1/admin/reservations')
      .set(authorization())
      .query({ municipalityId: SOLLANA_ID, facilityId })
      .expect(200);
  });

  it('reports a private incident and records its status history', async () => {
    const created = await request(server)
      .post('/v1/incidents')
      .set('X-Device-Id', deviceId)
      .send({
        municipalityId: SOLLANA_ID,
        category: 'alumbrado',
        description: 'Incidencia privada e2e',
      })
      .expect(201);
    const incidentId = jsonBody<{ id: string }>(created).id;

    await request(server)
      .get(`/v1/incidents/${incidentId}`)
      .set('X-Device-Id', otherDeviceId)
      .expect(403);

    await request(server)
      .get('/v1/incidents')
      .set('X-Device-Id', deviceId)
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ items: Array<{ id: string }> }>(response);
        expect(body.items).toEqual(
          expect.arrayContaining([expect.objectContaining({ id: incidentId })]),
        );
      });

    await request(server)
      .get('/v1/admin/incidents')
      .set(authorization())
      .query({ municipalityId: SOLLANA_ID })
      .expect(200);

    await request(server)
      .patch(`/v1/admin/incidents/${incidentId}/status`)
      .set(authorization())
      .send({ status: 'en_curso', note: 'Revisada en prueba e2e' })
      .expect(200)
      .expect((response) =>
        expect(jsonBody<{ status: string }>(response).status).toBe('en_curso'),
      );

    await request(server)
      .get(`/v1/incidents/${incidentId}`)
      .set('X-Device-Id', deviceId)
      .expect(200)
      .expect((response) => {
        const body = jsonBody<{ history: Array<{ status: string }> }>(response);
        expect(body.history).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ status: 'en_curso' }),
          ]),
        );
      });
  });

  it('creates a survey, enforces one vote per device and exports CSV', async () => {
    const created = await request(server)
      .post('/v1/admin/surveys')
      .set(authorization())
      .send({
        municipalityId: SOLLANA_ID,
        question: { es: '¿Opción e2e?' },
        closesAt: new Date(Date.now() + 86_400_000).toISOString(),
        resultsVisible: true,
        options: [{ es: 'Sí' }, { es: 'No' }],
      })
      .expect(201);
    const survey = jsonBody<{
      id: string;
      options: Array<{ id: string }>;
    }>(created);
    const surveyId = survey.id;
    const optionId = survey.options[0].id;

    await request(server)
      .post(`/v1/surveys/${surveyId}/vote`)
      .set('X-Device-Id', deviceId)
      .send({ optionId })
      .expect(204);

    await request(server)
      .post(`/v1/surveys/${surveyId}/vote`)
      .set('X-Device-Id', deviceId)
      .send({ optionId })
      .expect(409);

    await request(server)
      .get(`/v1/admin/surveys/${surveyId}/results.csv`)
      .set(authorization())
      .expect('Content-Type', /text\/csv/)
      .expect(200)
      .expect(({ text }) => expect(text).toContain('Sí'));

    await request(server)
      .delete(`/v1/admin/surveys/${surveyId}`)
      .set(authorization())
      .expect(204);
  });

  it('creates a form, enforces one submission and exports CSV', async () => {
    const created = await request(server)
      .post('/v1/admin/forms')
      .set(authorization())
      .send({
        municipalityId: SOLLANA_ID,
        title: { es: 'Formulario e2e' },
        description: { es: 'Formulario para pruebas e2e' },
        deadline: new Date(Date.now() + 86_400_000).toISOString(),
        fields: [
          {
            key: 'nombre',
            label: { es: 'Nombre' },
            type: 'text',
            required: true,
          },
        ],
      })
      .expect(201);
    const form = jsonBody<{ id: string; fields: Array<{ id: string }> }>(
      created,
    );
    const formId = form.id;
    const fieldId = form.fields[0].id;
    const submission = { answers: [{ fieldId, value: 'Cuadrilla e2e' }] };

    await request(server)
      .post(`/v1/forms/${formId}/submissions`)
      .set('X-Device-Id', deviceId)
      .send(submission)
      .expect(204);

    await request(server)
      .post(`/v1/forms/${formId}/submissions`)
      .set('X-Device-Id', deviceId)
      .send(submission)
      .expect(409);

    await request(server)
      .get(`/v1/admin/forms/${formId}/submissions.csv`)
      .set(authorization())
      .expect('Content-Type', /text\/csv/)
      .expect(200)
      .expect(({ text }) => expect(text).toContain('Cuadrilla e2e'));

    await request(server)
      .delete(`/v1/admin/forms/${formId}`)
      .set(authorization())
      .expect(204);
  });

  it('upserts and reads today duty pharmacy', async () => {
    const date = new Date().toISOString().slice(0, 10);
    await request(server)
      .put('/v1/admin/pharmacies/duty')
      .set(authorization())
      .send({
        municipalityId: SOLLANA_ID,
        date,
        pharmacyName: 'Farmacia e2e',
        address: 'Carrer Major, 1',
        phone: '961 000 999',
        schedule: '09:00 - 22:00',
      })
      .expect(200)
      .expect((response) =>
        expect(jsonBody<{ pharmacyName: string }>(response).pharmacyName).toBe(
          'Farmacia e2e',
        ),
      );

    await request(server)
      .get('/v1/pharmacies/duty/today')
      .query({ municipalityId: SOLLANA_ID })
      .expect(200)
      .expect((response) =>
        expect(jsonBody<{ pharmacyName: string }>(response).pharmacyName).toBe(
          'Farmacia e2e',
        ),
      );
  });

  it('revokes the refresh token on logout', async () => {
    await request(server)
      .post('/v1/admin/auth/logout')
      .set('Cookie', refreshCookie)
      .expect(201)
      .expect({ success: true });

    await request(server)
      .post('/v1/admin/auth/refresh')
      .set('Cookie', refreshCookie)
      .expect(401);
  });
});
