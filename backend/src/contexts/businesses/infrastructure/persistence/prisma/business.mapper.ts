import type {
  Business as PrismaBusiness,
  BusinessPhoto as PrismaBusinessPhoto,
} from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../../../domain/entities/business.entity';
import { BusinessPhoto } from '../../../domain/entities/business-photo.entity';
import { BusinessCategory } from '../../../domain/value-objects/business-category.vo';

export type PrismaBusinessWithPhotos = PrismaBusiness & {
  photos: PrismaBusinessPhoto[];
};

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

export class BusinessMapper {
  static photoToDomain(row: PrismaBusinessPhoto): BusinessPhoto {
    return BusinessPhoto.create({
      id: row.id,
      url: row.url,
      mimeType: row.mimeType,
      position: row.position,
    });
  }

  static toDomain(row: PrismaBusinessWithPhotos): Business {
    return Business.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      name: row.name,
      category: BusinessCategory.create(row.category),
      description: row.description
        ? LocalizedText.create(row.description as RawLocalizedJson)
        : null,
      address: row.address,
      phone: row.phone,
      email: row.email,
      website: row.website,
      schedule: row.schedule,
      active: row.active,
      createdAt: row.createdAt,
      photos: row.photos
        .slice()
        .sort((a, b) => a.position - b.position)
        .map((photo) => BusinessMapper.photoToDomain(photo)),
    });
  }
}
