import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NewsNotFoundError } from '../../domain/errors/news-errors';
import { NEWS_READER_PORT } from '../../domain/ports/news-reader.port';
import type { NewsReaderPort } from '../../domain/ports/news-reader.port';

@Injectable()
export class GetNewsDetailUseCase {
  constructor(
    @Inject(NEWS_READER_PORT) private readonly reader: NewsReaderPort,
  ) {}

  // El municipio es obligatorio: el aislamiento entre municipios se verifica
  // en el caso de uso, no solo en el controlador. Una noticia de otro pueblo
  // se responde como NO ENCONTRADA, no como prohibida: confirmar que existe
  // contenido ajeno ya es filtrar información.
  async execute(
    id: string,
    rawMunicipalityId: string,
  ): Promise<Result<NewsItem>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const news = await this.reader.findByIdPublished(id, municipalityId);
    if (!news) {
      return Result.failure(new NewsNotFoundError(id));
    }
    return Result.success(news);
  }
}
