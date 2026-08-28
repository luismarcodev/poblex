import type {
  News as PrismaNews,
  NewsAttachment as PrismaNewsAttachment,
} from '@prisma/client';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { NewsAttachment } from '../../../domain/entities/news-attachment.entity';
import { NewsItem } from '../../../domain/entities/news-item.entity';
import { NewsCategory } from '../../../domain/value-objects/news-category.vo';

export type PrismaNewsWithAttachments = PrismaNews & {
  attachments: PrismaNewsAttachment[];
};

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

export class NewsMapper {
  static toDomain(row: PrismaNewsWithAttachments): NewsItem {
    return NewsItem.create({
      id: row.id,
      municipalityId: MunicipalityId.create(row.municipalityId),
      title: LocalizedText.create(row.title as RawLocalizedJson),
      body: LocalizedText.create(row.body as RawLocalizedJson),
      imageUrl: row.imageUrl,
      category: NewsCategory.create(row.category),
      pinned: row.pinned,
      publishedAt: row.publishedAt,
      archived: row.archived,
      attachments: row.attachments.map((attachment) =>
        NewsAttachment.create(attachment),
      ),
      sourcePlatform: row.sourcePlatform?.toLowerCase() ?? null,
      sourceExternalPostId: row.sourceExternalPostId,
    });
  }
}
