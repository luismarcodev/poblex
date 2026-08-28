import type {
  SocialPlatform as PrismaSocialPlatform,
  SocialPublication as PrismaSocialPublication,
  SocialPublicationStatus as PrismaSocialPublicationStatus,
} from '@prisma/client';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { SocialPublication } from '../../../domain/entities/social-publication.entity';
import { SocialPlatform } from '../../../domain/value-objects/social-platform.vo';
import { SocialPublicationStatus } from '../../../domain/value-objects/social-publication-status.vo';

export class SocialPublicationMapper {
  static toDomain(row: PrismaSocialPublication): SocialPublication {
    return SocialPublication.create({
      id: row.id,
      newsId: row.newsId,
      municipalityId: MunicipalityId.create(row.municipalityId),
      platform: SocialPlatform.create(row.platform.toLowerCase()),
      status: SocialPublicationStatus.create(row.status.toLowerCase()),
      containerId: row.containerId,
      externalPostId: row.externalPostId,
      lastError: row.lastError,
      attemptCount: row.attemptCount,
      createdAt: row.createdAt,
      publishedAt: row.publishedAt,
    });
  }

  static toPrismaPlatform(platform: SocialPlatform): PrismaSocialPlatform {
    return platform.value.toUpperCase() as PrismaSocialPlatform;
  }

  static toPrismaStatus(
    status: SocialPublicationStatus,
  ): PrismaSocialPublicationStatus {
    return status.value.toUpperCase() as PrismaSocialPublicationStatus;
  }
}
