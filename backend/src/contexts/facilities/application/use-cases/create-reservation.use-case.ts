import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { Reservation } from '../../domain/entities/reservation.entity';
import {
  FacilityInactiveError,
  FacilityNotFoundError,
  SlotOutsideBookingWindowError,
  SlotOutsideOpeningHoursError,
  TooManyActiveReservationsError,
} from '../../domain/errors/facility-errors';
import { FACILITY_READER_PORT } from '../../domain/ports/facility-reader.port';
import type { FacilityReaderPort } from '../../domain/ports/facility-reader.port';
import { RESERVATION_READER_PORT } from '../../domain/ports/reservation-reader.port';
import type { ReservationReaderPort } from '../../domain/ports/reservation-reader.port';
import { RESERVATION_WRITER_PORT } from '../../domain/ports/reservation-writer.port';
import type { ReservationWriterPort } from '../../domain/ports/reservation-writer.port';
import { OpeningHours } from '../../domain/value-objects/opening-hours.vo';

export interface CreateReservationInput {
  facilityId: string;
  deviceId: string;
  // Instante exacto de inicio del hueco — el cliente lo elige de la lista
  // que ya ha devuelto GetFacilityAvailabilityUseCase, no se recalcula aquí
  // qué huecos existen, solo se revalida que este en concreto siga siendo
  // legítimo y libre.
  slotStart: string;
}

// Tope blando de reservas activas simultáneas por dispositivo e instalación:
// evita que alguien acapare todos los huecos de una pista. Umbral de
// partida, a ajustar con datos reales de uso, no a ojo — mismo criterio que
// el resto de límites del proyecto.
const MAX_ACTIVE_RESERVATIONS_PER_DEVICE = 3;

@Injectable()
export class CreateReservationUseCase {
  constructor(
    @Inject(FACILITY_READER_PORT) private readonly facilities: FacilityReaderPort,
    @Inject(RESERVATION_READER_PORT)
    private readonly reservationReader: ReservationReaderPort,
    @Inject(RESERVATION_WRITER_PORT)
    private readonly reservationWriter: ReservationWriterPort,
  ) {}

  async execute(input: CreateReservationInput): Promise<Result<Reservation>> {
    let deviceId: DeviceId;
    let slotStart: Date;
    try {
      deviceId = DeviceId.create(input.deviceId);
      slotStart = new Date(input.slotStart);
      if (Number.isNaN(slotStart.getTime())) {
        throw new Error('invalid date');
      }
    } catch {
      return Result.failure(
        new ValidationError(
          `Invalid deviceId or slotStart: "${input.deviceId}" / "${input.slotStart}"`,
        ),
      );
    }

    const facility = await this.facilities.findById(input.facilityId);
    if (!facility) {
      return Result.failure(new FacilityNotFoundError(input.facilityId));
    }
    if (!facility.active) {
      return Result.failure(new FacilityInactiveError(facility.id));
    }

    const now = new Date();
    if (!facility.isWithinBookingWindow(slotStart, now)) {
      return Result.failure(
        new SlotOutsideBookingWindowError(
          slotStart,
          facility.maxAdvanceBookingDays,
        ),
      );
    }

    const dayKey = OpeningHours.dayKeyFor(slotStart);
    const range = facility.openingHours.rangeFor(dayKey);
    const slotEnd = new Date(
      slotStart.getTime() + facility.slotDurationMinutes * 60_000,
    );
    if (!range || !this.withinRange(slotStart, slotEnd, range)) {
      return Result.failure(new SlotOutsideOpeningHoursError(slotStart));
    }

    const activeCount =
      await this.reservationReader.countActiveByDeviceAndFacility(
        deviceId.value,
        facility.id,
        now,
      );
    if (activeCount >= MAX_ACTIVE_RESERVATIONS_PER_DEVICE) {
      return Result.failure(
        new TooManyActiveReservationsError(
          deviceId.value,
          facility.id,
          MAX_ACTIVE_RESERVATIONS_PER_DEVICE,
        ),
      );
    }

    try {
      const reservation = await this.reservationWriter.create({
        facilityId: facility.id,
        municipalityId: facility.municipalityId,
        deviceId: deviceId.value,
        slotStart,
        slotEnd,
      });
      return Result.success(reservation);
    } catch (error) {
      return Result.failure(error as DomainError);
    }
  }

  private withinRange(
    slotStart: Date,
    slotEnd: Date,
    range: { open: string; close: string },
  ): boolean {
    const dayStart = new Date(slotStart);
    dayStart.setUTCHours(0, 0, 0, 0);
    const [openHour, openMinute] = range.open.split(':').map(Number);
    const [closeHour, closeMinute] = range.close.split(':').map(Number);
    const openAt = new Date(dayStart);
    openAt.setUTCHours(openHour, openMinute, 0, 0);
    const closeAt = new Date(dayStart);
    closeAt.setUTCHours(closeHour, closeMinute, 0, 0);
    return slotStart.getTime() >= openAt.getTime() && slotEnd.getTime() <= closeAt.getTime();
  }
}
