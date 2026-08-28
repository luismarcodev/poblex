import { Injectable } from '@nestjs/common';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import type {
  CreateNewsFromSocialPostParams,
  CreatedInboundNews,
  InboundNewsWriterPort,
} from '../../../domain/ports/inbound-news-writer.port';
import { SocialPlatform } from '../../../domain/value-objects/social-platform.vo';
import { SocialAccountMapper } from './social-account.mapper';

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

// Categoría fija de producto para todo lo que entra por esta vía — decisión
// cerrada, no configurable por el gestor.
const INBOUND_CATEGORY = 'redes-sociales';

// Escribe directo contra `prisma.news` — deliberadamente separado del
// NewsWriterPort del contexto `news` (ver decisión de arquitectura del
// módulo: la vía del gestor y la vía automática son flujos distintos).
@Injectable()
export class InboundNewsPrismaRepository implements InboundNewsWriterPort {
  constructor(private readonly prisma: PrismaService) {}

  async existsBySourcePost(
    municipalityId: MunicipalityId,
    platform: SocialPlatform,
    externalPostId: string,
  ): Promise<boolean> {
    const row = await this.prisma.news.findUnique({
      where: {
        municipalityId_sourcePlatform_sourceExternalPostId: {
          municipalityId: municipalityId.value,
          sourcePlatform: SocialAccountMapper.toPrismaPlatform(platform),
          sourceExternalPostId: externalPostId,
        },
      },
      select: { id: true },
    });
    return row !== null;
  }

  async createFromSocialPost(
    params: CreateNewsFromSocialPostParams,
  ): Promise<CreatedInboundNews> {
    const row = await this.prisma.news.create({
      data: {
        municipalityId: params.municipalityId.value,
        title: params.title.toJSON() as Prisma.InputJsonValue,
        body: params.body.toJSON() as Prisma.InputJsonValue,
        category: INBOUND_CATEGORY,
        imageUrl: params.imageUrl,
        pinned: false,
        publishedAt: new Date(),
        sourcePlatform: SocialAccountMapper.toPrismaPlatform(params.platform),
        sourceExternalPostId: params.externalPostId,
      },
    });
    return {
      id: row.id,
      title: LocalizedText.create(row.title as RawLocalizedJson),
      body: LocalizedText.create(row.body as RawLocalizedJson),
    };
  }
}
