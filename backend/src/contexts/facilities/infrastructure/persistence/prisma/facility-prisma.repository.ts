import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Facility } from '../../../domain/entities/facility.entity';
import type {
  FacilityReaderPort,
  FindFacilitiesParams,
} from '../../../domain/ports/facility-reader.port';
import type {
  CreateFacilityParams,
  FacilityWriterPort,
  UpdateFacilityFields,
} from '../../../domain/ports/facility-writer.port';
import { FacilityMapper } from './facility.mapper';

@Injectable()
export class FacilityPrismaRepository
  implements FacilityReaderPort, FacilityWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async find(params: FindFacilitiesParams): Promise<Facility[]> {
    const rows = await this.prisma.facility.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        category: params.category,
        active: params.onlyActive ? true : undefined,
      },
      orderBy: { createdAt: 'asc' },
    });
    return rows.map((row) => FacilityMapper.toDomain(row));
  }

  async findById(id: string): Promise<Facility | null> {
    const row = await this.prisma.facility.findUnique({ where: { id } });
    return row ? FacilityMapper.toDomain(row) : null;
  }

  async findByIdForMunicipality(
    id: string,
    municipalityId: import('../../../../../shared/domain/value-objects/municipality-id').MunicipalityId,
  ): Promise<Facility | null> {
    const row = await this.prisma.facility.findFirst({
      where: { id, municipalityId: municipalityId.value },
    });
    return row ? FacilityMapper.toDomain(row) : null;
  }

  async create(params: CreateFacilityParams): Promise<Facility> {
    const row = await this.prisma.facility.create({
      data: {
        municipalityId: params.municipalityId.value,
        name: params.name.toJSON() as Prisma.InputJsonValue,
        description: params.description
          ? (params.description.toJSON() as Prisma.InputJsonValue)
          : undefined,
        category: params.category,
        imageUrl: params.imageUrl,
        slotDurationMinutes: params.slotDurationMinutes,
        openingHours: params.openingHours.toJSON() as Prisma.InputJsonValue,
        feeNote: params.feeNote
          ? (params.feeNote.toJSON() as Prisma.InputJsonValue)
          : undefined,
        maxAdvanceBookingDays: params.maxAdvanceBookingDays,
      },
    });
    return FacilityMapper.toDomain(row);
  }

  async update(id: string, fields: UpdateFacilityFields): Promise<Facility> {
    const row = await this.prisma.facility.update({
      where: { id },
      data: {
        name: fields.name
          ? (fields.name.toJSON() as Prisma.InputJsonValue)
          : undefined,
        // Ojo: `fields.description?.toJSON()` colapsaría null a undefined
        // (encadenamiento opcional sobre null da undefined) y Prisma
        // interpretaría "no tocar el campo" en vez de "vaciarlo" — de ahí el
        // `Prisma.DbNull` explícito en vez de pasar `null` directamente.
        description:
          fields.description === undefined
            ? undefined
            : fields.description === null
              ? Prisma.DbNull
              : (fields.description.toJSON() as Prisma.InputJsonValue),
        category: fields.category,
        imageUrl: fields.imageUrl,
        slotDurationMinutes: fields.slotDurationMinutes,
        openingHours: fields.openingHours
          ? (fields.openingHours.toJSON() as Prisma.InputJsonValue)
          : undefined,
        feeNote:
          fields.feeNote === undefined
            ? undefined
            : fields.feeNote === null
              ? Prisma.DbNull
              : (fields.feeNote.toJSON() as Prisma.InputJsonValue),
        maxAdvanceBookingDays: fields.maxAdvanceBookingDays,
        active: fields.active,
      },
    });
    return FacilityMapper.toDomain(row);
  }
}
