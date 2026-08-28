import type {
  Reservation as PrismaReservation,
  ReservationCancellation as PrismaReservationCancellation,
} from '@prisma/client';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Reservation } from '../../../domain/entities/reservation.entity';
import { ReservationCancellation } from '../../../domain/entities/reservation-cancellation.entity';

export class ReservationMapper {
  static toDomain(row: PrismaReservation): Reservation {
    return Reservation.create({
      id: row.id,
      facilityId: row.facilityId,
      municipalityId: MunicipalityId.create(row.municipalityId),
      deviceId: row.deviceId,
      slotStart: row.slotStart,
      slotEnd: row.slotEnd,
      createdAt: row.createdAt,
    });
  }

  static cancellationToDomain(
    row: PrismaReservationCancellation,
  ): ReservationCancellation {
    return ReservationCancellation.create({
      id: row.id,
      facilityId: row.facilityId,
      municipalityId: MunicipalityId.create(row.municipalityId),
      deviceId: row.deviceId,
      slotStart: row.slotStart,
      slotEnd: row.slotEnd,
      cancelledBy: row.cancelledBy,
      cancelNote: row.cancelNote,
      cancelledAt: row.cancelledAt,
    });
  }
}
