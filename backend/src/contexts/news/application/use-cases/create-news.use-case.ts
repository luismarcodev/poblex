import { Inject, Injectable, Logger, Optional } from '@nestjs/common';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NewsForbiddenError } from '../../domain/errors/news-errors';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type { NewsWriterPort } from '../../domain/ports/news-writer.port';
import { NEWS_SOCIAL_SHARE_PORT } from '../../domain/ports/news-social-share.port';
import type { NewsSocialSharePort } from '../../domain/ports/news-social-share.port';
import { NewsCategory } from '../../domain/value-objects/news-category.vo';

export interface CreateNewsInput {
  managerId: string;
  // Lista, no uno: `manager_municipalities` es N:M y el backoffice permite
  // publicar el mismo bando en varios municipios de golpe.
  municipalityIds: string[];
  title: { es?: string; va?: string };
  body: { es?: string; va?: string };
  category: string;
  imageUrl?: string;
  pinned?: boolean;
  publishedAt?: Date;
  // Checkbox por noticia en el editor — nunca automático para todas.
  shareToChannels?: string[];
}

@Injectable()
export class CreateNewsUseCase {
  private readonly logger = new Logger(CreateNewsUseCase.name);

  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly broadcast: BroadcastNotifier,
    // Opcional a propósito: los tests que no registran SocialModule no deben
    // romperse por una dependencia que no les concierne.
    @Optional()
    @Inject(NEWS_SOCIAL_SHARE_PORT)
    private readonly socialShare?: NewsSocialSharePort,
  ) {}

  async execute(input: CreateNewsInput): Promise<Result<NewsItem[]>> {
    let municipalityIds: MunicipalityId[];
    let title: LocalizedText;
    let body: LocalizedText;
    let category: NewsCategory;
    try {
      municipalityIds = input.municipalityIds.map((id) =>
        MunicipalityId.create(id),
      );
      title = LocalizedText.create(input.title);
      body = LocalizedText.create(input.body);
      category = NewsCategory.create(input.category);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    // Se comprueban TODOS los municipios antes de escribir ninguno: publicar
    // en tres de cuatro y fallar en el último dejaría el bando a medias sin
    // forma de saberlo desde el backoffice.
    for (const municipalityId of municipalityIds) {
      const isAuthorized = await this.managers.isManagerOfMunicipality(
        input.managerId,
        municipalityId.value,
      );
      if (!isAuthorized) {
        return Result.failure(
          new NewsForbiddenError(input.managerId, municipalityId.value),
        );
      }
    }

    const publishedAt = input.publishedAt ?? new Date();
    const created: NewsItem[] = [];

    for (const municipalityId of municipalityIds) {
      const news = await this.writer.create({
        municipalityId,
        title,
        body,
        category,
        imageUrl: input.imageUrl,
        pinned: input.pinned ?? false,
        publishedAt,
      });
      created.push(news);

      // Difusión por topic: misma noticia para todo el municipio, un envío por
      // idioma. Se dispara desde el caso de uso vía puerto, nunca desde el
      // controlador.
      await this.broadcast.broadcast({
        municipalityId: municipalityId.value,
        channel: 'news',
        title,
        body,
        data: {
          type: 'news',
          id: news.id,
          municipalityId: municipalityId.value,
        },
      });

      if (input.shareToChannels?.length && this.socialShare) {
        try {
          await this.socialShare.shareNews({
            newsId: news.id,
            municipalityId: municipalityId.value,
            platforms: input.shareToChannels,
            title,
            body,
            imageUrl: input.imageUrl,
          });
        } catch (error) {
          // Un fallo de redes sociales nunca tumba la creación de la
          // noticia, que ya está guardada y difundida por push.
          this.logger.error(
            `Failed to share news ${news.id} to social channels: ${String(error)}`,
          );
        }
      }
    }

    return Result.success(created);
  }
}
