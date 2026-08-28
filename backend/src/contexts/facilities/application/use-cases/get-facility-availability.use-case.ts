import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { Facility } from '../../domain/entities/facility.entity';
import {
  FacilityInactiveError,
  FacilityNotFoundError,
} from '../../domain/errors/facility-errors';
import { FACILITY_READER_PORT } from '../../domain/ports/facility-reader.port';
import type { FacilityReaderPort } from '../../domain/ports/facility-reader.port';
import { RESERVATION_READER_PORT } from '../../domain/ports/reservation-reader.port';
import type { ReservationReaderPort } from '../../domain/ports/reservation-reader.port';
import { OpeningHours } from '../../domain/value-objects/opening-hours.vo';

export interface GetFacilityAvailabilityInput {
  facilityId: string;
  // "YYYY-MM-DD" — se interpreta como día de calendario UTC, ver el
  // comentario de OpeningHours sobre por qué no hay conversión de zona
  // horaria todavía.
  date: string;
}

export interface AvailabilitySlot {
  start: Date;
  end: Date;
}

export interface FacilityAvailability {
  facility: Facility;
  slots: AvailabilitySlot[];
}

const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

@Injectable()
export class GetFacilityAvailabilityUseCase {
  constructor(
    @Inject(FACILITY_READER_PORT) private readonly facilities: FacilityReaderPort,
    @Inject(RESERVATION_READER_PORT)
    private readonly reservations: ReservationReaderPort,
  ) {}

  async execute(
    input: GetFacilityAvailabilityInput,
  ): Promise<Result<FacilityAvailability>> {
    if (!DATE_REGEX.test(input.date)) {
      return Result.failure(
        new ValidationError(
          `Invalid date: "${input.date}" (expected YYYY-MM-DD)`,
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

    const dayStart = new Date(`${input.date}T00:00:00.000Z`);
    const dayEnd = new Date(dayStart.getTime() + 86_400_000);
    const dayKey = OpeningHours.dayKeyFor(dayStart);
    const range = facility.openingHours.rangeFor(dayKey);
    if (!range) {
      return Result.success({ facility, slots: [] });
    }

    const [openHour, openMinute] = range.open.split(':').map(Number);
    const [closeHour, closeMinute] = range.close.split(':').map(Number);
    const openAt = new Date(dayStart);
    openAt.setUTCHours(openHour, openMinute, 0, 0);
    const closeAt = new Date(dayStart);
    closeAt.setUTCHours(closeHour, closeMinute, 0, 0);

    const stepMs = facility.slotDurationMinutes * 60_000;
    const now = new Date();
    const existing = await this.reservations.findByFacilityInRange(
      facility.id,
      dayStart,
      dayEnd,
    );
    const taken = new Set(existing.map((r) => r.slotStart.getTime()));

    const slots: AvailabilitySlot[] = [];
    for (
      let slotStart = openAt.getTime();
      slotStart + stepMs <= closeAt.getTime();
      slotStart += stepMs
    ) {
      const start = new Date(slotStart);
      const end = new Date(slotStart + stepMs);
      if (taken.has(start.getTime())) continue;
      if (!facility.isWithinBookingWindow(start, now)) continue;
      slots.push({ start, end });
    }

    return Result.success({ facility, slots });
  }
}
