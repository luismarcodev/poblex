import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NotifyDevicesService } from '../../../devices/application/services/notify-devices.service';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import {
  Incident,
  IncidentProps,
  PHOTO_RETENTION_DAYS,
} from '../../domain/entities/incident.entity';
import {
  IncidentForbiddenError,
  IncidentNotFoundError,
  InvalidIncidentStatusTransitionError,
} from '../../domain/errors/incident-errors';
import type { IncidentReaderPort } from '../../domain/ports/incident-reader.port';
import type {
  ChangeStatusParams,
  IncidentWriterPort,
} from '../../domain/ports/incident-writer.port';
import { IncidentStatus } from '../../domain/value-objects/incident-status.vo';
import { ChangeIncidentStatusUseCase } from './change-incident-status.use-case';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';
const DEVICE_ID = '7c9e6679-7425-40de-944b-e07fc1f90ae7';
const MANAGER_ID = '9a8b7c6d-5e4f-4a3b-9c8d-7e6f5a4b3c2d';

function buildIncident(overrides: Partial<IncidentProps> = {}): Incident {
  return Incident.create({
    id: 'incident-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    deviceId: DeviceId.create(DEVICE_ID),
    category: 'alumbrado',
    description: 'Farola fundida',
    photoUrl: 'https://cdn.example/incidents/photo.jpg',
    photoPurgeAt: null,
    lat: null,
    lng: null,
    status: IncidentStatus.received(),
    createdAt: new Date('2026-02-01T10:00:00Z'),
    updatedAt: new Date('2026-02-01T10:00:00Z'),
    ...overrides,
  });
}

interface Harness {
  useCase: ChangeIncidentStatusUseCase;
  changeStatus: jest.Mock<Promise<Incident>, [ChangeStatusParams]>;
  notify: jest.Mock;
}

function buildHarness(options: {
  incident: Incident | null;
  authorized?: boolean;
}): Harness {
  const incident = options.incident;
  const reader = {
    findById: jest.fn().mockResolvedValue(incident),
  } as unknown as IncidentReaderPort;

  const changeStatus = jest
    .fn<Promise<Incident>, [ChangeStatusParams]>()
    .mockResolvedValue(incident ?? buildIncident());
  const writer = { changeStatus } as unknown as IncidentWriterPort;

  const managers = {
    isManagerOfMunicipality: jest
      .fn()
      .mockResolvedValue(options.authorized ?? true),
  } as unknown as ManagerRepositoryPort;

  const notify = jest.fn().mockResolvedValue(undefined);
  const notifyDevices = { notify } as unknown as NotifyDevicesService;

  return {
    useCase: new ChangeIncidentStatusUseCase(
      reader,
      writer,
      managers,
      notifyDevices,
    ),
    changeStatus,
    notify,
  };
}

describe('ChangeIncidentStatusUseCase', () => {
  it('fails when the incident does not exist', async () => {
    const { useCase } = buildHarness({ incident: null });

    const result = await useCase.execute({
      incidentId: 'missing',
      managerId: MANAGER_ID,
      status: 'en_curso',
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      IncidentNotFoundError,
    );
  });

  // El aislamiento entre municipios se verifica en el caso de uso.
  it('refuses a manager from another municipality', async () => {
    const { useCase, changeStatus } = buildHarness({
      incident: buildIncident(),
      authorized: false,
    });

    const result = await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'en_curso',
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      IncidentForbiddenError,
    );
    expect(changeStatus).not.toHaveBeenCalled();
  });

  it('rejects an unknown status', async () => {
    const { useCase, changeStatus } = buildHarness({
      incident: buildIncident(),
    });

    const result = await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'archivada',
    });

    expect(result.isFailure).toBe(true);
    expect(changeStatus).not.toHaveBeenCalled();
  });

  it('does not reopen a resolved incident or cancel its photo purge', async () => {
    const purgeAt = new Date('2027-02-01T10:00:00Z');
    const { useCase, changeStatus } = buildHarness({
      incident: buildIncident({
        status: IncidentStatus.create('resuelta'),
        photoPurgeAt: purgeAt,
      }),
    });

    const result = await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'recibido',
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      InvalidIncidentStatusTransitionError,
    );
    expect(changeStatus).not.toHaveBeenCalled();
  });

  it('does not schedule a photo purge while the incident is still open', async () => {
    const { useCase, changeStatus } = buildHarness({
      incident: buildIncident(),
    });

    await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'en_curso',
    });

    expect(changeStatus.mock.calls[0][0].photoPurgeAt).toBeNull();
  });

  // Requisito legal: al resolver arranca el reloj de retención de la foto.
  it('schedules the photo purge when the incident is resolved', async () => {
    const { useCase, changeStatus } = buildHarness({
      incident: buildIncident(),
    });

    const before = Date.now();
    await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'resuelta',
    });

    const purgeAt = changeStatus.mock.calls[0][0].photoPurgeAt;
    expect(purgeAt).not.toBeNull();
    expect(purgeAt!.getTime()).toBeGreaterThanOrEqual(
      before + PHOTO_RETENTION_DAYS * 86_400_000,
    );
  });

  it('schedules no purge when the incident has no photo', async () => {
    const { useCase, changeStatus } = buildHarness({
      incident: buildIncident({ photoUrl: null }),
    });

    await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'resuelta',
    });

    expect(changeStatus.mock.calls[0][0].photoPurgeAt).toBeNull();
  });

  // Dirigido por token al dispositivo que la reportó, nunca por topic.
  it('notifies only the reporting device', async () => {
    const { useCase, notify } = buildHarness({ incident: buildIncident() });

    await useCase.execute({
      incidentId: 'incident-1',
      managerId: MANAGER_ID,
      status: 'resuelta',
    });

    expect(notify).toHaveBeenCalledTimes(1);
    const [deviceIds, notification] = notify.mock.calls[0] as [
      DeviceId[],
      { data: Record<string, string> },
    ];
    expect(deviceIds).toHaveLength(1);
    expect(deviceIds[0].value).toBe(DEVICE_ID);
    expect(notification.data).toEqual({
      type: 'incident',
      id: 'incident-1',
      status: 'resuelta',
    });
  });
});
