import { Injectable } from '@nestjs/common';
import type {
  NewsSocialSharePort,
  ShareNewsParams,
} from '../../../news/domain/ports/news-social-share.port';
import { PublishNewsToSocialChannelsUseCase } from '../../application/use-cases/publish-news-to-social-channels.use-case';

// Pieza que rompe el ciclo de módulos: `news` importa `SocialModule` para
// obtener este puerto, `social` nunca importa `NewsModule`.
@Injectable()
export class NewsSocialShareAdapter implements NewsSocialSharePort {
  constructor(private readonly publish: PublishNewsToSocialChannelsUseCase) {}

  async shareNews(params: ShareNewsParams): Promise<void> {
    await this.publish.execute({
      newsId: params.newsId,
      municipalityId: params.municipalityId,
      platforms: params.platforms,
      title: params.title,
      body: params.body,
      imageUrl: params.imageUrl,
    });
  }
}
