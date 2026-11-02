import { PrismaPg } from '@prisma/adapter-pg';
import * as argon2 from 'argon2';
import { Prisma, PrismaClient } from '@prisma/client';

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

const SOLLANA_ID = '11111111-1111-4111-8111-111111111111';
const DEMO_MANAGER_EMAIL = 'gestor@sollana.poblex.es';
const DEMO_MANAGER_PASSWORD = 'CambiaEstaContrasena123';

const DAY_MS = 86_400_000;
const now = Date.now();

// -----------------------------------------------------------------------------
// PENDIENTE ANTES DE LA DEMO AL ALCALDE
//
// Verificado con fuentes reales (web oficial del Ajuntament de Sollana —
// sollana.es —, callejero.net y la propia AEMET) el 11 de agosto de 2026:
//   - Topónimos: Plaça Major (ahí está el ayuntamiento, no "Plaça de
//     l'Ajuntament"), Avinguda de la Constitució, Avinguda Ribera Baixa,
//     Carrer Francesc de Vinatea, Carrer Rei Jaume I, Plaça Joan Fuster,
//     Carrer Joanot Martorell.
//   - Coordenadas del centro del pueblo (aproximadas, no geocodificación
//     exacta del edificio): 39.2779662, -0.3830231.
//   - `aemetZoneCode`: zona AEMET real de Sollana es "Litoral sur de
//     Valencia", código 774604 — confirmado contra aemet.es dos veces
//     (ficha del municipio y feed de avisos de la Comunitat Valenciana).
//   - Fiestas patronales reales: Sant Antoni (12 de enero, misa y bendición
//     de animales en la plaza) y las patronales de agosto del Santíssim
//     Crist de la Pietat (semana taurina, 17-24 de agosto).
//
// SIGUE SIN VERIFICAR — todavía inventado, no lo des por bueno delante del
// alcalde:
//   - Nombres de comercios (Bar Casa Pepe, Perruqueria Marisa...): no hay
//     directorio comercial real consultado, solo topónimos.
//   - Nombres y horario de farmacias de guardia: la carga real exige el
//     calendario oficial del Colegio de Farmacéuticos de Valencia.
//   - Los textos de noticias son plausibles pero NO son copias de
//     comunicaciones reales del ayuntamiento — sigue el punto 1 original.
// -----------------------------------------------------------------------------

async function main(): Promise<void> {
  const municipality = await prisma.municipality.upsert({
    where: { slug: 'sollana' },
    // Sincroniza los campos de contenido investigado (zona AEMET, color) en
    // cada reseed, no solo en la creación — si no, un municipio ya existente
    // de una ejecución anterior se queda con datos viejos para siempre.
    update: {
      aemetZoneCode: '774604',
      primaryColor: '#AC3509',
    },
    create: {
      id: SOLLANA_ID,
      slug: 'sollana',
      name: 'Sollana',
      province: 'Valencia',
      // Zona AEMET "Litoral sur de Valencia" — ver cabecera del fichero.
      aemetZoneCode: '774604',
      // Coral "Modern Civic Coral" (rebrand Stitch, docs/design-system.md
      // §0.1) — Sollana usa el color por defecto de Poblex, no uno propio.
      primaryColor: '#AC3509',
      logoUrl: null,
      languages: ['es', 'va'],
      active: true,
    },
  });

  const passwordHash = await argon2.hash(DEMO_MANAGER_PASSWORD);
  const manager = await prisma.manager.upsert({
    where: { email: DEMO_MANAGER_EMAIL },
    update: {},
    create: {
      email: DEMO_MANAGER_EMAIL,
      passwordHash,
      displayName: 'Gestor demo Sollana',
    },
  });

  await prisma.managerMunicipality.upsert({
    where: {
      managerId_municipalityId: {
        managerId: manager.id,
        municipalityId: municipality.id,
      },
    },
    update: {},
    create: { managerId: manager.id, municipalityId: municipality.id },
  });

  await seedNews(municipality.id);
  await seedEvents(municipality.id);
  await seedAlert(municipality.id, manager.id);
  await seedSurvey(municipality.id);
  await seedForm(municipality.id);
  await seedDutyPharmacies(municipality.id);
  await seedBusinesses(municipality.id);
  await seedFacilities(municipality.id);

  console.log('Seed completado:', {
    municipality: municipality.slug,
    manager: manager.email,
    demoPassword: DEMO_MANAGER_PASSWORD,
  });
}

async function seedNews(municipalityId: string): Promise<void> {
  if ((await prisma.news.count({ where: { municipalityId } })) > 0) return;

  const items: Prisma.NewsCreateManyInput[] = [
    {
      municipalityId,
      title: {
        es: 'Corte de agua programado en la Avinguda de la Constitució',
        va: "Tall d'aigua programat a l'Avinguda de la Constitució",
      },
      body: {
        es: 'El próximo martes de 9:00 a 14:00 habrá corte de suministro de agua potable en la Avinguda de la Constitució y calles adyacentes por trabajos de renovación de la red. Se recomienda hacer acopio la noche anterior.',
        va: "El pròxim dimarts de 9:00 a 14:00 hi haurà tall de subministrament d'aigua potable a l'Avinguda de la Constitució i carrers adjacents per treballs de renovació de la xarxa. Es recomana fer provisió la nit anterior.",
      },
      category: 'servicios',
      pinned: true,
      publishedAt: new Date(now - DAY_MS),
      archived: false,
    },
    {
      municipalityId,
      title: {
        es: 'Nuevo horario de la recogida de enseres',
        va: "Nou horari de la recollida d'estris",
      },
      body: {
        es: 'A partir de este mes, la recogida de enseres domésticos pasa a ser los primeros lunes de cada mes. Hay que dejar los objetos en la acera a partir de las 20:00 de la víspera y avisar previamente en las oficinas municipales.',
        va: "A partir d'aquest mes, la recollida d'estris domèstics passa a ser els primers dilluns de cada mes. Cal deixar els objectes a la vorera a partir de les 20:00 de la vespra i avisar prèviament a les oficines municipals.",
      },
      category: 'servicios',
      pinned: false,
      publishedAt: new Date(now - 3 * DAY_MS),
      archived: false,
    },
    {
      municipalityId,
      // Solo en castellano: sirve para probar el fallback de idioma en la app.
      title: { es: 'Convocatoria de pleno ordinario' },
      body: {
        es: 'El pleno ordinario del Ayuntamiento se celebrará el último jueves de mes a las 20:00 en el salón de plenos. La sesión es pública y el orden del día está disponible en el tablón de anuncios.',
      },
      category: 'general',
      pinned: false,
      publishedAt: new Date(now - 10 * DAY_MS),
      archived: false,
    },
    {
      municipalityId,
      title: {
        es: 'Programa de las Fiestas Patronales del Santíssim Crist de la Pietat',
        va: 'Programa de les Festes Patronals del Santíssim Crist de la Pietat',
      },
      body: {
        es: 'Del 17 al 24 de agosto, semana taurina y actos en honor al Santíssim Crist de la Pietat. El programa completo estará disponible en el tablón de anuncios y en la Plaça Major.',
        va: 'Del 17 al 24 d’agost, setmana taurina i actes en honor al Santíssim Crist de la Pietat. El programa complet estarà disponible al tauler d’anuncis i a la Plaça Major.',
      },
      category: 'general',
      pinned: true,
      publishedAt: new Date(now - 2 * DAY_MS),
      archived: false,
    },
    {
      municipalityId,
      // Archivada: sirve para probar el listado del gestor con includeArchived.
      title: { es: 'Campaña de vacunación de la gripe (finalizada)' },
      body: {
        es: 'La campaña de vacunación de la gripe del pasado invierno ya ha finalizado. Gracias a todos los vecinos que participaron.',
      },
      category: 'sanitaria',
      pinned: false,
      publishedAt: new Date(now - 200 * DAY_MS),
      archived: true,
    },
  ];

  await prisma.news.createMany({ data: items });
}

async function seedEvents(municipalityId: string): Promise<void> {
  if ((await prisma.event.count({ where: { municipalityId } })) > 0) return;

  const items: Prisma.EventCreateManyInput[] = [
    {
      municipalityId,
      title: {
        es: 'Mercado municipal semanal',
        va: 'Mercat municipal setmanal',
      },
      description: {
        es: 'Mercado ambulante en la Plaça Major con puestos de alimentación, textil y menaje.',
        va: 'Mercat ambulant a la Plaça Major amb parades d’alimentació, tèxtil i parament.',
      },
      startAt: new Date(now + 2 * DAY_MS),
      endAt: new Date(now + 2 * DAY_MS + 5 * 3_600_000),
      locationName: 'Plaça Major',
      // Centro del pueblo, no geocodificación exacta del edificio — ver
      // cabecera del fichero.
      lat: 39.2779662,
      lng: -0.3830231,
      category: 'mercado',
    },
    {
      municipalityId,
      title: {
        es: 'Fiestas Patronales del Santíssim Crist de la Pietat',
        va: 'Festes Patronals del Santíssim Crist de la Pietat',
      },
      description: {
        es: 'Semana taurina y actos religiosos y festivos en honor al patrón de Sollana, con la Plaça Major como centro de la celebración.',
        va: 'Setmana taurina i actes religiosos i festius en honor al patró de Sollana, amb la Plaça Major com a centre de la celebració.',
      },
      startAt: new Date(Date.UTC(2026, 7, 17, 8, 0, 0)),
      endAt: new Date(Date.UTC(2026, 7, 24, 23, 0, 0)),
      locationName: 'Plaça Major',
      lat: 39.2779662,
      lng: -0.3830231,
      category: 'fiestas',
    },
    {
      municipalityId,
      title: {
        es: 'Taller de memoria para personas mayores',
        va: 'Taller de memòria per a persones majors',
      },
      description: {
        es: 'Sesión gratuita en el centro social. Plazas limitadas, hay que inscribirse en las oficinas municipales.',
        va: 'Sessió gratuïta al centre social. Places limitades, cal inscriure’s a les oficines municipals.',
      },
      startAt: new Date(now + 9 * DAY_MS),
      endAt: null,
      locationName: 'Centre social',
      lat: null,
      lng: null,
      category: 'social',
    },
    {
      municipalityId,
      // Ya celebrado: sirve para probar el filtro includePast del gestor.
      title: { es: 'Charla sobre el Parc Natural de l’Albufera' },
      description: {
        es: 'Charla divulgativa sobre el entorno natural del municipio y las aves de la Albufera.',
      },
      startAt: new Date(now - 14 * DAY_MS),
      endAt: new Date(now - 14 * DAY_MS + 2 * 3_600_000),
      locationName: 'Casa de cultura',
      lat: null,
      lng: null,
      category: 'cultural',
    },
  ];

  await prisma.event.createMany({ data: items });
}

async function seedAlert(
  municipalityId: string,
  managerId: string,
): Promise<void> {
  if ((await prisma.alert.count({ where: { municipalityId } })) > 0) return;

  // Alerta MANUAL: lleva created_by obligatoriamente. Las de origen AEMET las
  // crea la tarea programada y llevan created_by nulo más su aemet_id.
  await prisma.alert.create({
    data: {
      municipalityId,
      source: 'MANUAL',
      severity: 'AMARILLO',
      phenomenonType: 'METEOROLOGICO',
      phenomenon: 'Lluvias',
      body: {
        es: 'Se prevén lluvias intensas durante la tarde. Evita desplazamientos innecesarios por los caminos rurales.',
        va: 'Es preveuen pluges intenses durant la vesprada. Evita desplaçaments innecessaris pels camins rurals.',
      },
      startAt: new Date(now - 3_600_000),
      endAt: new Date(now + 12 * 3_600_000),
      aemetId: null,
      createdBy: managerId,
    },
  });

  // Alerta de incendio/evacuación para la demo comercial: Sollana en sí no
  // tiene riesgo real de incendio forestal (marjal y arrozales, Ribera
  // Baixa), pero el objetivo de negocio es enseñar en cualquier demo que la
  // app ya soporta este tipo de aviso con la máxima prioridad — pensado
  // para vender a un municipio con ese riesgo real. Sin endAt: se mantiene
  // vigente y el banner de Inicio la recoge de inmediato al abrir la app.
  await prisma.alert.create({
    data: {
      municipalityId,
      source: 'MANUAL',
      severity: 'ROJO',
      phenomenonType: 'INCENDIO',
      phenomenon: 'Incendio forestal — evacuación preventiva de la zona norte',
      body: {
        es: 'Incendio forestal activo cerca del término municipal. Protección Civil ha ordenado la evacuación preventiva de la zona norte. Sigue las indicaciones de los equipos de emergencia y evita la zona.',
        va: "Incendi forestal actiu prop del terme municipal. Protecció Civil ha ordenat l'evacuació preventiva de la zona nord. Segueix les indicacions dels equips d'emergència i evita la zona.",
      },
      startAt: new Date(now - 900_000),
      endAt: null,
      aemetId: null,
      createdBy: managerId,
    },
  });
}

async function seedSurvey(municipalityId: string): Promise<void> {
  if ((await prisma.survey.count({ where: { municipalityId } })) > 0) return;

  await prisma.survey.create({
    data: {
      municipalityId,
      question: {
        es: '¿Qué prefieres que se instale en el parque municipal?',
        va: 'Què prefereixes que s’instal·le al parc municipal?',
      },
      closesAt: new Date(now + 20 * DAY_MS),
      // Oculto mientras esté abierta: enseñar el recuento en vivo condiciona
      // el voto. Al cerrar se muestra igualmente.
      resultsVisible: false,
      options: {
        create: [
          {
            label: {
              es: 'Zona de juegos infantiles',
              va: 'Zona de jocs infantils',
            },
            position: 0,
          },
          {
            label: {
              es: 'Aparatos de gimnasia para mayores',
              va: 'Aparells de gimnàstica per a majors',
            },
            position: 1,
          },
          {
            label: { es: 'Más sombra y bancos', va: 'Més ombra i bancs' },
            position: 2,
          },
        ],
      },
    },
  });
}

async function seedForm(municipalityId: string): Promise<void> {
  if ((await prisma.form.count({ where: { municipalityId } })) > 0) return;

  // El caso de uso del PRD: el censo de paellas que el gestor exporta a CSV.
  await prisma.form.create({
    data: {
      municipalityId,
      title: {
        es: 'Inscripción al concurso de paellas',
        va: 'Inscripció al concurs de paelles',
      },
      description: {
        es: 'Rellena este formulario para apuntar a tu cuadrilla. Una inscripción por dispositivo.',
        va: 'Ompli aquest formulari per a apuntar la teua colla. Una inscripció per dispositiu.',
      },
      deadline: new Date(now + 30 * DAY_MS),
      fields: {
        create: [
          {
            key: 'nombre_cuadrilla',
            label: { es: 'Nombre de la cuadrilla', va: 'Nom de la colla' },
            type: 'TEXT',
            required: true,
            options: Prisma.DbNull,
            position: 0,
          },
          {
            key: 'numero_comensales',
            label: { es: 'Número de comensales', va: 'Nombre de comensals' },
            type: 'NUMBER',
            required: true,
            options: Prisma.DbNull,
            position: 1,
          },
          {
            key: 'turno',
            label: { es: 'Turno preferido', va: 'Torn preferit' },
            type: 'SELECT',
            required: false,
            options: ['mañana', 'tarde'],
            position: 2,
          },
          {
            key: 'necesita_toma_electrica',
            label: {
              es: '¿Necesitas toma eléctrica?',
              va: 'Necessites presa elèctrica?',
            },
            type: 'BOOLEAN',
            required: false,
            options: Prisma.DbNull,
            position: 3,
          },
        ],
      },
    },
  });
}

async function seedDutyPharmacies(municipalityId: string): Promise<void> {
  if ((await prisma.dutyPharmacy.count({ where: { municipalityId } })) > 0) {
    return;
  }

  // Carga MANUAL por diseño: no hay API oficial abierta en la Comunidad
  // Valenciana y no se hace scraping de terceros para un dato sanitario.
  // TODO(demo): sustituir por las farmacias reales de Sollana y su calendario.
  const today = new Date();
  const startOfDay = Date.UTC(
    today.getUTCFullYear(),
    today.getUTCMonth(),
    today.getUTCDate(),
  );

  const rows: Prisma.DutyPharmacyCreateManyInput[] = Array.from(
    { length: 7 },
    (_, offset) => ({
      municipalityId,
      date: new Date(startOfDay + offset * DAY_MS),
      pharmacyName:
        offset % 2 === 0 ? 'Farmàcia Avinguda Constitució' : 'Farmàcia Plaça',
      address:
        offset % 2 === 0 ? 'Avinguda de la Constitució, 12' : 'Plaça Major, 3',
      phone: offset % 2 === 0 ? '961 000 001' : '961 000 002',
      schedule: '09:00 - 22:00',
    }),
  );

  await prisma.dutyPharmacy.createMany({ data: rows });
}

async function seedBusinesses(municipalityId: string): Promise<void> {
  if ((await prisma.business.count({ where: { municipalityId } })) > 0) {
    return;
  }

  // TODO(demo): sustituir por comercios reales de Sollana antes de la demo
  // al alcalde, igual que el resto de contenido de este fichero.
  const rows: Prisma.BusinessCreateManyInput[] = [
    {
      municipalityId,
      name: 'Bar Casa Pepe',
      category: 'bar',
      description: {
        es: 'Bar de toda la vida en el centro del pueblo, tapas y menú diario.',
        va: 'Bar de tota la vida al centre del poble, tapes i menú diari.',
      },
      address: 'Carrer Francesc de Vinatea, 8',
      phone: '961 000 010',
      email: null,
      website: null,
      schedule: '08:00 - 23:00',
      active: true,
    },
    {
      municipalityId,
      name: 'Panadería Forn de la Plaça',
      category: 'alimentacion',
      description: Prisma.DbNull,
      address: 'Plaça Major, 5',
      phone: null,
      email: null,
      website: null,
      schedule: '07:00 - 14:00',
      active: true,
    },
    {
      municipalityId,
      name: 'Perruqueria Marisa',
      category: 'peluqueria',
      description: {
        es: 'Peluquería unisex, cita previa por teléfono o WhatsApp.',
      },
      address: 'Carrer Joanot Martorell, 22',
      phone: '961 000 011',
      email: 'info@perruqueriamarisa.example',
      website: 'https://perruqueriamarisa.example',
      schedule: 'L-V 9:00-13:00 y 16:00-20:00',
      active: true,
    },
    {
      municipalityId,
      name: 'Taller Mecànic Ribera',
      category: 'taller',
      description: Prisma.DbNull,
      address: 'Polígon Industrial, nau 4',
      phone: '961 000 012',
      email: null,
      website: null,
      schedule: null,
      active: true,
    },
    {
      municipalityId,
      name: 'Ferreteria Sollana (cerrada)',
      category: 'servicios',
      description: Prisma.DbNull,
      address: null,
      phone: null,
      email: null,
      website: null,
      schedule: null,
      // Ejemplo de comercio despublicado: sirve para probar el filtro
      // "incluir desactivados" del backoffice y que no aparezca en la app.
      active: false,
    },
  ];

  await prisma.business.createMany({ data: rows });
}

// TODO(demo): nombres de pista plausibles, no un directorio real de
// instalaciones municipales de Sollana — igual que los comercios, sigue el
// aviso "SIGUE SIN VERIFICAR" de la cabecera del fichero. Sin reservas
// sembradas: las genera la demo en vivo tocando la app.
async function seedFacilities(municipalityId: string): Promise<void> {
  if ((await prisma.facility.count({ where: { municipalityId } })) > 0) {
    return;
  }

  const weekdayHours = { open: '09:00', close: '22:00' };
  const weekendHours = { open: '09:00', close: '14:00' };
  const fullWeek = {
    mon: weekdayHours,
    tue: weekdayHours,
    wed: weekdayHours,
    thu: weekdayHours,
    fri: weekdayHours,
    sat: weekendHours,
    sun: null,
  };

  const rows: Prisma.FacilityCreateManyInput[] = [
    {
      municipalityId,
      name: { es: 'Pista de pádel municipal', va: 'Pista de pàdel municipal' },
      description: {
        es: 'Pista cubierta junto al polideportivo.',
        va: 'Pista coberta al costat del poliesportiu.',
      },
      category: 'Pádel',
      imageUrl: null,
      slotDurationMinutes: 60,
      openingHours: fullWeek,
      feeNote: Prisma.DbNull,
      maxAdvanceBookingDays: 14,
      active: true,
    },
    {
      municipalityId,
      name: { es: 'Pista de tenis municipal', va: 'Pista de tennis municipal' },
      description: Prisma.DbNull,
      category: 'Tenis',
      imageUrl: null,
      slotDurationMinutes: 60,
      openingHours: fullWeek,
      feeNote: Prisma.DbNull,
      maxAdvanceBookingDays: 14,
      active: true,
    },
    {
      municipalityId,
      name: {
        es: 'Zona de barbacoa municipal',
        va: 'Zona de barbacoa municipal',
      },
      description: {
        es: 'Zona de barbacoa con mesas, en el área recreativa del río.',
        va: 'Zona de barbacoa amb taules, a l’àrea recreativa del riu.',
      },
      category: 'Barbacoa',
      imageUrl: null,
      slotDurationMinutes: 180,
      openingHours: {
        mon: null,
        tue: null,
        wed: null,
        thu: null,
        fri: weekdayHours,
        sat: { open: '09:00', close: '23:00' },
        sun: { open: '09:00', close: '23:00' },
      },
      feeNote: {
        es: '3€/hora, se abona en el ayuntamiento antes de la reserva.',
        va: '3€/hora, s’abona a l’ajuntament abans de la reserva.',
      },
      maxAdvanceBookingDays: 30,
      active: true,
    },
  ];

  await prisma.facility.createMany({ data: rows });
}

main()
  .catch((error: unknown) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => {
    void prisma.$disconnect();
  });
