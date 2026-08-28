import { Alert } from '../../domain/entities/alert.entity';
import { AlertResponseDto } from '../http/dto/alert-response.dto';

// La respuesta pública NO expone created_by ni updated_by: son datos de
// auditoría interna, no información para el vecino.
export class AlertHttpMapper {
  static toResponseDto(alert: Alert): AlertResponseDto {
    return {
      id: alert.id,
      municipalityId: alert.municipalityId.value,
      source: alert.source.value,
      severity: alert.severity.value,
      phenomenonType: alert.phenomenonType.value,
      phenomenon: alert.phenomenon,
      body: alert.body.toJSON(),
      startAt: alert.startAt.toISOString(),
      endAt: alert.endAt?.toISOString() ?? null,
      forcesNotification: alert.severity.forcesNotification,
    };
  }
}
