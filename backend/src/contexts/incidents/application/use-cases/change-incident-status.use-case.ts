import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { NotifyDevicesService } from '../../../devices/application/services/notify-devices.service';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Incident } from '../../domain/entities/incident.entity';
import {
  IncidentForbiddenError,
  IncidentNotFoundError,
  InvalidIncidentStatusTransitionError,
} from '../../domain/errors/incident-errors';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type { IncidentReaderPort } from '../../domain/ports/incident-reader.port';
import { INCIDENT_WRITER_PORT } from '../../domain/ports/incident-writer.port';
import type { IncidentWriterPort } from '../../domain/ports/incident-writer.port';
import { IncidentStatus } from '../../domain/value-objects/incident-status.vo';

export interface ChangeIncidentStatusInput {
  incidentId: string;
  managerId: string;
  status: string;
  note?: string;
}

const STATUS_LABELS: Record<string, { es: string; va: string }> = {
  recibido: { es: 'recibida', va: 'rebuda' },
  en_curso: { es: 'en curso', va: 'en curs' },
  resuelta: { es: 'resuelta', va: 'resolta' },
};

@Injectable()
export class ChangeIncidentStatusUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    @Inject(INCIDENT_WRITER_PORT) private readonly writer: IncidentWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly notifyDevices: NotifyDevicesService,
  ) {}

  async execute(input: ChangeIncidentStatusInput): Promise<Result<Incident>> {
    let status: IncidentStatus;
    try {
      status = IncidentStatus.create(input.status);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const existing = await this.reader.findById(input.incidentId);
    if (!existing) {
      return Result.failure(new IncidentNotFoundError(input.incidentId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new IncidentForbiddenError(
          input.managerId,
          existing.municipalityId.value,
        ),
      );
    }

    if (!existing.status.canTransitionTo(status)) {
      return Result.failure(
        new InvalidIncidentStatusTransitionError(
          existing.status.value,
          status.value,
        ),
      );
    }

    // Al resolver arranca el reloj de retención de la foto: 12 meses y se
    // borra. Requisito legal.
    const now = new Date();
    const photoPurgeAt = status.isResolved
      ? existing.photoPurgeDateFor(now)
      : existing.photoPurgeAt;

    const updated = await this.writer.changeStatus({
      incidentId: input.incidentId,
      status,
      note: input.note ?? null,
      changedBy: input.managerId,
      photoPurgeAt,
    });

    // Dirigido por token al dispositivo que la reportó, en SU idioma. Nunca
    // por topic: el resto del municipio no tiene por qué enterarse.
    const label = STATUS_LABELS[status.value];
    await this.notifyDevices.notify([existing.deviceId], {
      title: {
        es: 'Actualización de tu incidencia',
        va: 'Actualització de la teua incidència',
      },
      body: {
        es: `Tu incidencia está ${label.es}.`,
        va: `La teua incidència està ${label.va}.`,
      },
      data: { type: 'incident', id: updated.id, status: status.value },
    });

    return Result.success(updated);
  }
}
