import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import type {
  CreateRefreshTokenParams,
  RefreshTokenRepositoryPort,
  StoredRefreshToken,
} from '../../../domain/ports/refresh-token-repository.port';

@Injectable()
export class RefreshTokenPrismaRepository implements RefreshTokenRepositoryPort {
  constructor(private readonly prisma: PrismaService) {}

  async create(params: CreateRefreshTokenParams): Promise<void> {
    await this.prisma.managerRefreshToken.create({
      data: {
        managerId: params.managerId,
        tokenHash: params.tokenHash,
        expiresAt: params.expiresAt,
      },
    });
  }

  async findByHash(tokenHash: string): Promise<StoredRefreshToken | null> {
    const row = await this.prisma.managerRefreshToken.findFirst({
      where: { tokenHash },
    });
    if (!row) return null;
    return {
      id: row.id,
      managerId: row.managerId,
      expiresAt: row.expiresAt,
      revokedAt: row.revokedAt,
    };
  }

  async revokeIfActive(id: string): Promise<boolean> {
    const result = await this.prisma.managerRefreshToken.updateMany({
      where: { id, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return result.count === 1;
  }

  async revokeAllForManager(managerId: string): Promise<void> {
    await this.prisma.managerRefreshToken.updateMany({
      where: { managerId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}
