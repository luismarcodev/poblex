import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type {
  NewsWriterPort,
  UpdateNewsFields,
} from '../../domain/ports/news-writer.port';
import { NewsCategory } from '../../domain/value-objects/news-category.vo';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';

export interface UpdateNewsInput {
  id: string;
  managerId: string;
  title?: { es?: string; va?: string };
  body?: { es?: string; va?: string };
  category?: string;
  // undefined keeps the current image; null removes it explicitly.
  imageUrl?: string | null;
}

@Injectable()
export class UpdateNewsUseCase {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    private readonly authorize: AuthorizeNewsMutationService,
  ) {}

  async execute(input: UpdateNewsInput): Promise<Result<NewsItem>> {
    const authResult = await this.authorize.ensureMutable(
      input.id,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    let fields: UpdateNewsFields;
    try {
      fields = {
        title: input.title ? LocalizedText.create(input.title) : undefined,
        body: input.body ? LocalizedText.create(input.body) : undefined,
        category: input.category
          ? NewsCategory.create(input.category)
          : undefined,
        imageUrl: input.imageUrl,
      };
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const updated = await this.writer.update(input.id, fields);
    return Result.success(updated);
  }
}
