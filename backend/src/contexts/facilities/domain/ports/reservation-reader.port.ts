import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Reservation } from '../entities/reservation.entity';

export interface ReservationListResult {
  items: Reservation[];
  nextCursor: string | null;
}

export interface FindMyReservationsParams {
  deviceId: string;
  cursor?: string;
  limit: number;
}

export interface FindManagedReservationsParams {
  municipalityId: MunicipalityId;
  facilityId?: string;
  cursor?: string;
  limit: number;
}

export interface ReservationReaderPort {
  findById(id: string): Promise<Reservation | null>;
  findMine(params: FindMyReservationsParams): Promise<ReservationListResult>;
  findManaged(
    params: FindManagedReservationsParams,
  ): Promise<ReservationListResult>;
  // Reservas vigentes de una instalación en un rango — la disponibilidad se
  // calcula restando estas al horario de apertura, no se guardan huecos
  // vacíos en base de datos.
  findByFacilityInRange(
    facilityId: string,
    rangeStart: Date,
    rangeEnd: Date,
  ): Promise<Reservation[]>;
  // Para el límite blando de reservas activas simultáneas por dispositivo e
  // instalación (ver create-reservation.use-case.ts).
  countActiveByDeviceAndFacility(
    deviceId: string,
    facilityId: string,
    now: Date,
  ): Promise<number>;
}

export const RESERVATION_READER_PORT = Symbol('RESERVATION_READER_PORT');
