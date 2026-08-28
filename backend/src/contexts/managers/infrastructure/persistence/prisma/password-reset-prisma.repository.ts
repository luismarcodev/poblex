import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import type {
  CreatePasswordResetParams,
  PasswordResetRepositoryPort,
  StoredPasswordReset,
} from '../../../domain/ports/password-reset-repository.port';

@Injectable()
export class PasswordResetPrismaRepository implements PasswordResetRepositoryPort {
  constructor(private readonly prisma: PrismaService) {}

  async create(params: CreatePasswordResetParams): Promise<void> {
    await this.prisma.managerPasswordReset.create({
      data: {
        managerId: params.managerId,
        tokenHash: params.tokenHash,
        expiresAt: params.expiresAt,
      },
    });
  }

  async findByHash(tokenHash: string): Promise<StoredPasswordReset | null> {
    const row = await this.prisma.managerPasswordReset.findFirst({
      where: { tokenHash },
    });
    if (!row) return null;
    return {
      id: row.id,
      managerId: row.managerId,
      expiresAt: row.expiresAt,
      usedAt: row.usedAt,
    };
  }

  async markUsed(id: string): Promise<void> {
    await this.prisma.managerPasswordReset.update({
      where: { id },
      data: { usedAt: new Date() },
    });
  }
}
