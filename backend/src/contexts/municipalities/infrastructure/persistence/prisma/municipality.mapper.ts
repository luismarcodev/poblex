import type { Municipality as PrismaMunicipality } from '@prisma/client';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Municipality } from '../../../domain/entities/municipality.entity';

export class MunicipalityMapper {
  static toDomain(row: PrismaMunicipality): Municipality {
    return Municipality.create({
      id: MunicipalityId.create(row.id),
      slug: row.slug,
      name: row.name,
      province: row.province,
      aemetZoneCode: row.aemetZoneCode,
      primaryColor: row.primaryColor,
      logoUrl: row.logoUrl,
      languages: row.languages,
      active: row.active,
    });
  }
}
