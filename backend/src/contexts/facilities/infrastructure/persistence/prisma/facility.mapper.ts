import type { Facility as PrismaFacility } from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Facility } from '../../../domain/entities/facility.entity';
import { OpeningHours } from '../../../domain/value-objects/opening-hours.vo';

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

export class FacilityMapper {
  static toDomain(row: PrismaFacility): Facility {
    return Facility.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      name: LocalizedText.create(row.name as RawLocalizedJson),
      description: row.description
        ? LocalizedText.create(row.description as RawLocalizedJson)
        : null,
      category: row.category,
      imageUrl: row.imageUrl,
      slotDurationMinutes: row.slotDurationMinutes,
      openingHours: OpeningHours.create(row.openingHours),
      feeNote: row.feeNote
        ? LocalizedText.create(row.feeNote as RawLocalizedJson)
        : null,
      maxAdvanceBookingDays: row.maxAdvanceBookingDays,
      active: row.active,
      createdAt: row.createdAt,
    });
  }
}
