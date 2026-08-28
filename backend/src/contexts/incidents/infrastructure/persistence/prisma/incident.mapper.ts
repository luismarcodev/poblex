import type {
  Incident as PrismaIncident,
  IncidentStatus as PrismaIncidentStatus,
  IncidentStatusHistory as PrismaIncidentStatusHistory,
} from '@prisma/client';
import { DeviceId } from '../../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { IncidentStatusChange } from '../../../domain/entities/incident-status-change.entity';
import { Incident } from '../../../domain/entities/incident.entity';
import { IncidentStatus } from '../../../domain/value-objects/incident-status.vo';

export class IncidentMapper {
  static toDomain(row: PrismaIncident): Incident {
    return Incident.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      deviceId: DeviceId.create(row.deviceId),
      category: row.category,
      description: row.description,
      photoUrl: row.photoUrl,
      photoPurgeAt: row.photoPurgeAt,
      lat: row.lat,
      lng: row.lng,
      status: IncidentStatus.create(row.status.toLowerCase()),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    });
  }

  static historyToDomain(
    row: PrismaIncidentStatusHistory,
  ): IncidentStatusChange {
    return IncidentStatusChange.create({
      id: row.id,
      incidentId: row.incidentId,
      status: IncidentStatus.create(row.status.toLowerCase()),
      note: row.note,
      changedAt: row.changedAt,
      changedBy: row.changedBy,
    });
  }

  static toPrismaStatus(status: IncidentStatus): PrismaIncidentStatus {
    return status.value.toUpperCase() as PrismaIncidentStatus;
  }
}
