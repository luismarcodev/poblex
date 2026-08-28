import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Manager } from '../../../domain/entities/manager.entity';
import type { ManagerRepositoryPort } from '../../../domain/ports/manager-repository.port';
import { ManagerMapper } from './manager.mapper';

@Injectable()
export class ManagerPrismaRepository implements ManagerRepositoryPort {
  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email: string): Promise<Manager | null> {
    const row = await this.prisma.manager.findUnique({ where: { email } });
    return row ? ManagerMapper.toDomain(row) : null;
  }

  async findById(id: string): Promise<Manager | null> {
    const row = await this.prisma.manager.findUnique({ where: { id } });
    return row ? ManagerMapper.toDomain(row) : null;
  }

  async updatePasswordHash(
    managerId: string,
    passwordHash: string,
  ): Promise<void> {
    await this.prisma.manager.update({
      where: { id: managerId },
      data: { passwordHash },
    });
  }

  async isManagerOfMunicipality(
    managerId: string,
    municipalityId: string,
  ): Promise<boolean> {
    const row = await this.prisma.managerMunicipality.findUnique({
      where: { managerId_municipalityId: { managerId, municipalityId } },
    });
    return row !== null;
  }

  async findMunicipalityIdsOf(managerId: string): Promise<string[]> {
    const rows = await this.prisma.managerMunicipality.findMany({
      where: { managerId },
      select: { municipalityId: true },
    });
    return rows.map((row) => row.municipalityId);
  }
}
