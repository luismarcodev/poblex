import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { SocialPublication } from '../../../domain/entities/social-publication.entity';
import type {
  CreateSocialPublicationParams,
  SocialPublicationReaderPort,
  SocialPublicationWriterPort,
  UpdateSocialPublicationStatusParams,
} from '../../../domain/ports/social-publication.port';
import { SocialPublicationMapper } from './social-publication.mapper';

@Injectable()
export class SocialPublicationPrismaRepository
  implements SocialPublicationReaderPort, SocialPublicationWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async findByNews(newsId: string): Promise<SocialPublication[]> {
    const rows = await this.prisma.socialPublication.findMany({
      where: { newsId },
    });
    return rows.map((row) => SocialPublicationMapper.toDomain(row));
  }

  async findPendingInstagram(): Promise<SocialPublication[]> {
    const rows = await this.prisma.socialPublication.findMany({
      where: {
        platform: 'INSTAGRAM',
        status: { in: ['CONTAINER_CREATED', 'PROCESSING'] },
      },
      orderBy: { createdAt: 'asc' },
    });
    return rows.map((row) => SocialPublicationMapper.toDomain(row));
  }

  async create(
    params: CreateSocialPublicationParams,
  ): Promise<SocialPublication> {
    const platform = SocialPublicationMapper.toPrismaPlatform(params.platform);

    // Reintentable: reutiliza la fila existente vía UNIQUE([newsId, platform])
    // en vez de acumular intentos duplicados, y arranca limpia desde PENDING.
    const row = await this.prisma.socialPublication.upsert({
      where: {
        newsId_platform: { newsId: params.newsId, platform },
      },
      create: {
        newsId: params.newsId,
        municipalityId: params.municipalityId.value,
        platform,
        status: 'PENDING',
        attemptCount: 1,
      },
      update: {
        status: 'PENDING',
        containerId: null,
        externalPostId: null,
        lastError: null,
        publishedAt: null,
        attemptCount: { increment: 1 },
      },
    });
    return SocialPublicationMapper.toDomain(row);
  }

  async updateStatus(
    id: string,
    fields: UpdateSocialPublicationStatusParams,
  ): Promise<SocialPublication> {
    const row = await this.prisma.socialPublication.update({
      where: { id },
      data: {
        status: SocialPublicationMapper.toPrismaStatus(fields.status),
        containerId: fields.containerId,
        externalPostId: fields.externalPostId,
        lastError: fields.lastError,
        publishedAt: fields.publishedAt,
      },
    });
    return SocialPublicationMapper.toDomain(row);
  }
}
