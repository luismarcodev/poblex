import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Municipality } from '../../../domain/entities/municipality.entity';
import { MunicipalityReaderPort } from '../../../domain/ports/municipality-reader.port';
import { MunicipalityMapper } from './municipality.mapper';

@Injectable()
export class MunicipalityPrismaRepository implements MunicipalityReaderPort {
  constructor(private readonly prisma: PrismaService) {}

  async findAllActive(): Promise<Municipality[]> {
    const rows = await this.prisma.municipality.findMany({
      where: { active: true },
      orderBy: { name: 'asc' },
    });
    return rows.map((row) => MunicipalityMapper.toDomain(row));
  }

  async findAllWithAemetZone(): Promise<Municipality[]> {
    const rows = await this.prisma.municipality.findMany({
      where: { active: true, aemetZoneCode: { not: null } },
    });
    return rows.map((row) => MunicipalityMapper.toDomain(row));
  }

  async findActiveById(id: MunicipalityId): Promise<Municipality | null> {
    const row = await this.prisma.municipality.findFirst({
      where: { id: id.value, active: true },
    });
    return row ? MunicipalityMapper.toDomain(row) : null;
  }
}
