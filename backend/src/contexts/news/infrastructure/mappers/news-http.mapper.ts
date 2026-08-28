import { NewsItem } from '../../domain/entities/news-item.entity';
import {
  ManagedNewsResponseDto,
  NewsResponseDto,
} from '../http/dto/news-response.dto';

// El servidor devuelve el objeto bilingüe COMPLETO (es + va), sin resolver
// a un solo idioma — el cliente decide y permite el conmutador manual.
export class NewsHttpMapper {
  static toResponseDto(news: NewsItem): NewsResponseDto {
    return {
      id: news.id,
      municipalityId: news.municipalityId.value,
      title: news.title.toJSON(),
      body: news.body.toJSON(),
      imageUrl: news.imageUrl,
      category: news.category.value,
      pinned: news.pinned,
      publishedAt: news.publishedAt.toISOString(),
      archived: news.archived,
      attachments: news.attachments.map((attachment) => ({
        id: attachment.id,
        name: attachment.name,
        url: attachment.url,
        mimeType: attachment.mimeType,
      })),
    };
  }

  // Solo para el gestor: expone el origen de redes sociales, que al vecino
  // no le corresponde ver.
  static toManagedResponseDto(news: NewsItem): ManagedNewsResponseDto {
    return {
      ...this.toResponseDto(news),
      sourcePlatform: news.sourcePlatform,
      sourceExternalPostId: news.sourceExternalPostId,
    };
  }
}
