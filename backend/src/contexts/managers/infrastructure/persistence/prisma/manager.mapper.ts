import type { Manager as PrismaManager } from '@prisma/client';
import { Manager } from '../../../domain/entities/manager.entity';

export class ManagerMapper {
  static toDomain(row: PrismaManager): Manager {
    return Manager.create({
      id: row.id,
      email: row.email,
      passwordHash: row.passwordHash,
      displayName: row.displayName,
    });
  }
}
