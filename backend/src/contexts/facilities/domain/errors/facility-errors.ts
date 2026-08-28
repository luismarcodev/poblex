import {
  ConflictError,
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class FacilityNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Facility not found: ${id}`);
  }
}

export class FacilityForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

export class FacilityInactiveError extends ValidationError {
  constructor(id: string) {
    super(`Facility ${id} is not currently accepting reservations`);
  }
}

export class SlotOutsideOpeningHoursError extends ValidationError {
  constructor(slotStart: Date) {
    super(`${slotStart.toISOString()} falls outside the facility's opening hours`);
  }
}

export class SlotOutsideBookingWindowError extends ValidationError {
  constructor(slotStart: Date, maxAdvanceBookingDays: number) {
    super(
      `${slotStart.toISOString()} is in the past or beyond the ${maxAdvanceBookingDays}-day booking window`,
    );
  }
}

// Se lanza tanto si la comprobación previa en el caso de uso encuentra el
// hueco ocupado como si la restricción UNIQUE de la base de datos rechaza el
// INSERT por una condición de carrera — el vecino ve el mismo error limpio
// en los dos casos, nunca un 500. ConflictError (409), no ValidationError
// (400): la petición era válida cuando se envió, solo ha perdido la carrera.
export class SlotAlreadyBookedError extends ConflictError {
  constructor(facilityId: string, slotStart: Date) {
    super(`Slot already booked: facility ${facilityId} at ${slotStart.toISOString()}`);
  }
}

export class TooManyActiveReservationsError extends ValidationError {
  constructor(deviceId: string, facilityId: string, limit: number) {
    super(
      `Device ${deviceId} already has ${limit} active reservations for facility ${facilityId}`,
    );
  }
}

export class ReservationNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Reservation not found: ${id}`);
  }
}

export class ReservationNotOwnedError extends ForbiddenError {
  constructor(reservationId: string) {
    super(`Reservation ${reservationId} does not belong to this device`);
  }
}
