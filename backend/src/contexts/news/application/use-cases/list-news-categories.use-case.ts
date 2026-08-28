import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NEWS_READER_PORT } from '../../domain/ports/news-reader.port';
import type { NewsReaderPort } from '../../domain/ports/news-reader.port';
import { NewsCategory } from '../../domain/value-objects/news-category.vo';

// Alimenta la barra de filtros del cliente. Devuelve las categorías que de
// verdad existen en el municipio, no una lista cerrada: la categoría es una
// etiqueta abierta y el gestor puede inventar una nueva desde el backoffice.
@Injectable()
export class ListNewsCategoriesUseCase {
  constructor(
    @Inject(NEWS_READER_PORT) private readonly reader: NewsReaderPort,
  ) {}

  async execute(rawMunicipalityId: string): Promise<Result<NewsCategory[]>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const categories = await this.reader.findCategories(municipalityId);
    return Result.success(categories);
  }
}
