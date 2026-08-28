import { IncidentStatusChange } from '../../domain/entities/incident-status-change.entity';
import { Incident } from '../../domain/entities/incident.entity';
import {
  IncidentResponseDto,
  IncidentStatusChangeDto,
} from '../http/dto/incident-response.dto';

// La respuesta NO expone device_id ni changed_by: el vecino no necesita el
// identificador de su propio dispositivo de vuelta, y el gestor que cambió el
// estado es dato interno.
export class IncidentHttpMapper {
  static toResponseDto(incident: Incident): IncidentResponseDto {
    return {
      id: incident.id,
      municipalityId: incident.municipalityId.value,
      category: incident.category,
      description: incident.description,
      photoUrl: incident.photoUrl,
      lat: incident.lat,
      lng: incident.lng,
      status: incident.status.value,
      createdAt: incident.createdAt.toISOString(),
      updatedAt: incident.updatedAt.toISOString(),
    };
  }

  static toStatusChangeDto(
    change: IncidentStatusChange,
  ): IncidentStatusChangeDto {
    return {
      status: change.status.value,
      note: change.note,
      changedAt: change.changedAt.toISOString(),
    };
  }
}
