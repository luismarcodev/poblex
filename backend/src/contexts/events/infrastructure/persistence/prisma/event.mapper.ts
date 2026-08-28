import type { Event as PrismaEvent } from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { MunicipalEvent } from '../../../domain/entities/event.entity';
import { EventCategory } from '../../../domain/value-objects/event-category.vo';

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

export class EventMapper {
  static toDomain(row: PrismaEvent): MunicipalEvent {
    return MunicipalEvent.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      title: LocalizedText.create(row.title as RawLocalizedJson),
      description: LocalizedText.create(row.description as RawLocalizedJson),
      startAt: row.startAt,
      endAt: row.endAt,
      locationName: row.locationName,
      lat: row.lat,
      lng: row.lng,
      category: EventCategory.create(row.category),
    });
  }
}
