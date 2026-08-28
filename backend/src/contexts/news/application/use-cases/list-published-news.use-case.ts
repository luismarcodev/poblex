import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NEWS_READER_PORT } from '../../domain/ports/news-reader.port';
import type {
  NewsListResult,
  NewsReaderPort,
} from '../../domain/ports/news-reader.port';
import { NewsCategory } from '../../domain/value-objects/news-category.vo';

export interface ListPublishedNewsInput {
  municipalityId: string;
  category?: string;
  cursor?: string;
  limit?: number;
  // Histórico: solo las archivadas. El vecino nunca borra nada a mano, así
  // que las de más de 90 días viven aquí y no desaparecen.
  archived?: boolean;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListPublishedNewsUseCase {
  constructor(
    @Inject(NEWS_READER_PORT) private readonly reader: NewsReaderPort,
  ) {}

  async execute(
    input: ListPublishedNewsInput,
  ): Promise<Result<NewsListResult>> {
    let municipalityId: MunicipalityId;
    let category: NewsCategory | undefined;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      // El value object valida el formato de slug y devuelve ValidationError
      // si no cuadra, así que una categoría inventada da 400 y no un listado
      // vacío silencioso.
      category = input.category
        ? NewsCategory.create(input.category)
        : undefined;
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const limit =
      input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
        ? input.limit
        : DEFAULT_LIMIT;

    const params = {
      municipalityId,
      category,
      cursor: input.cursor,
      limit,
    };

    const result = input.archived
      ? await this.reader.findArchived(params)
      : await this.reader.findPublished(params);
    return Result.success(result);
  }
}
