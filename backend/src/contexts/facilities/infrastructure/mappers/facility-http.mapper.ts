import { Facility } from '../../domain/entities/facility.entity';
import { AvailabilitySlot } from '../../application/use-cases/get-facility-availability.use-case';
import {
  AvailabilitySlotDto,
  FacilityResponseDto,
} from '../http/dto/facility-response.dto';

export class FacilityHttpMapper {
  static toResponseDto(facility: Facility): FacilityResponseDto {
    return {
      id: facility.id,
      municipalityId: facility.municipalityId.value,
      name: facility.name.toJSON(),
      description: facility.description?.toJSON() ?? null,
      category: facility.category,
      imageUrl: facility.imageUrl,
      slotDurationMinutes: facility.slotDurationMinutes,
      openingHours: facility.openingHours.toJSON(),
      feeNote: facility.feeNote?.toJSON() ?? null,
      maxAdvanceBookingDays: facility.maxAdvanceBookingDays,
      active: facility.active,
    };
  }

  static toSlotDto(slot: AvailabilitySlot): AvailabilitySlotDto {
    return {
      start: slot.start.toISOString(),
      end: slot.end.toISOString(),
    };
  }
}
