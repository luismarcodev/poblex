import { Injectable } from '@nestjs/common';
import type { DutyPharmacy as PrismaDutyPharmacy } from '@prisma/client';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { DutyPharmacy } from '../../../domain/entities/duty-pharmacy.entity';
import type {
  DutyPharmacyReaderPort,
  DutyPharmacyWriterPort,
  FindPharmaciesParams,
  UpsertDutyPharmacyParams,
} from '../../../domain/ports/duty-pharmacy.port';

function toDomain(row: PrismaDutyPharmacy): DutyPharmacy {
  return DutyPharmacy.create({
    id: row.id,
    municipalityId: MunicipalityId.create(row.municipalityId),
    date: row.date,
    pharmacyName: row.pharmacyName,
    address: row.address,
    phone: row.phone,
    schedule: row.schedule,
  });
}

@Injectable()
export class DutyPharmacyPrismaRepository
  implements DutyPharmacyReaderPort, DutyPharmacyWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async findInRange(params: FindPharmaciesParams): Promise<DutyPharmacy[]> {
    const rows = await this.prisma.dutyPharmacy.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        date: { gte: params.from, lte: params.to },
      },
      orderBy: { date: 'asc' },
    });
    return rows.map((row) => toDomain(row));
  }

  async findByDate(
    municipalityId: MunicipalityId,
    date: Date,
  ): Promise<DutyPharmacy | null> {
    const row = await this.prisma.dutyPharmacy.findUnique({
      where: {
        municipalityId_date: {
          municipalityId: municipalityId.value,
          date,
        },
      },
    });
    return row ? toDomain(row) : null;
  }

  async upsert(params: UpsertDutyPharmacyParams): Promise<DutyPharmacy> {
    const row = await this.prisma.dutyPharmacy.upsert({
      where: {
        municipalityId_date: {
          municipalityId: params.municipalityId.value,
          date: params.date,
        },
      },
      create: {
        municipalityId: params.municipalityId.value,
        date: params.date,
        pharmacyName: params.pharmacyName,
        address: params.address,
        phone: params.phone,
        schedule: params.schedule,
      },
      update: {
        pharmacyName: params.pharmacyName,
        address: params.address,
        phone: params.phone,
        schedule: params.schedule,
      },
    });
    return toDomain(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.dutyPharmacy.delete({ where: { id } });
  }
}
