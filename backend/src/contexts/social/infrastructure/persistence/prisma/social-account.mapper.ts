import type {
  SocialAccount as PrismaSocialAccount,
  SocialAccountStatus as PrismaSocialAccountStatus,
  SocialPlatform as PrismaSocialPlatform,
} from '@prisma/client';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import {
  SocialAccount,
  SocialAccountStatusKind,
} from '../../../domain/entities/social-account.entity';
import { SocialPlatform } from '../../../domain/value-objects/social-platform.vo';

// Los enums de Prisma van en mayúsculas; los del dominio, en minúsculas y con
// significado propio. La traducción vive aquí, igual que en AlertMapper.
export class SocialAccountMapper {
  static toDomain(row: PrismaSocialAccount): SocialAccount {
    return SocialAccount.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      platform: SocialPlatform.create(row.platform.toLowerCase()),
      externalAccountId: row.externalAccountId,
      accountName: row.accountName,
      tokenExpiresAt: row.tokenExpiresAt,
      status: row.status.toLowerCase() as SocialAccountStatusKind,
      lastErrorMessage: row.lastErrorMessage,
      connectedByManagerId: row.connectedByManagerId,
      connectedAt: row.connectedAt,
      lastRefreshedAt: row.lastRefreshedAt,
    });
  }

  static toPrismaPlatform(platform: SocialPlatform): PrismaSocialPlatform {
    return platform.value.toUpperCase() as PrismaSocialPlatform;
  }

  static toPrismaStatus(
    status: SocialAccount['status'],
  ): PrismaSocialAccountStatus {
    return status.toUpperCase() as PrismaSocialAccountStatus;
  }
}
