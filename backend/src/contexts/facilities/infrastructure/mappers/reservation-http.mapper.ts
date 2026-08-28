import { Reservation } from '../../domain/entities/reservation.entity';
import { ReservationResponseDto } from '../http/dto/reservation-response.dto';

// Deliberadamente no expone deviceId: ni al listado público (es el propio
// dispositivo quien pregunta "las mías", ya lo sabe) ni al del gestor
// (auditoría interna, no información de cara al listado — mismo criterio
// que AlertHttpMapper con created_by/updated_by).
export class ReservationHttpMapper {
  static toResponseDto(reservation: Reservation): ReservationResponseDto {
    return {
      id: reservation.id,
      facilityId: reservation.facilityId,
      municipalityId: reservation.municipalityId.value,
      slotStart: reservation.slotStart.toISOString(),
      slotEnd: reservation.slotEnd.toISOString(),
    };
  }
}
