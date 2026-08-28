import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Reservation } from '../entities/reservation.entity';
import { ReservationCancellation } from '../entities/reservation-cancellation.entity';

export interface CreateReservationParams {
  facilityId: string;
  municipalityId: MunicipalityId;
  deviceId: string;
  slotStart: Date;
  slotEnd: Date;
}

export interface CancelReservationParams {
  reservation: Reservation;
  // Null si cancela el propio vecino.
  cancelledBy: string | null;
  cancelNote: string | null;
}

export interface ReservationWriterPort {
  // Debe usar INSERT puro (nunca upsert): un choque de unicidad tiene que
  // fallar, no sobrescribir silenciosamente la reserva de otro vecino. El
  // adaptador Prisma traduce el código P2002 a SlotAlreadyBookedError.
  create(params: CreateReservationParams): Promise<Reservation>;
  // Borra la reserva viva e inserta el registro de cancelación en la misma
  // transacción — el hueco queda libre al instante.
  cancel(params: CancelReservationParams): Promise<ReservationCancellation>;
}

export const RESERVATION_WRITER_PORT = Symbol('RESERVATION_WRITER_PORT');
