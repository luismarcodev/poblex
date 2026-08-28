import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { BUSINESS_READER_PORT } from '../../domain/ports/business-reader.port';
import type { BusinessReaderPort } from '../../domain/ports/business-reader.port';
import { BusinessCategory } from '../../domain/value-objects/business-category.vo';

// Alimenta la barra de filtros del cliente y el autocompletado del editor
// del backoffice. Devuelve las categorías que de verdad existen, no una
// lista cerrada.
@Injectable()
export class ListBusinessCategoriesUseCase {
  constructor(
    @Inject(BUSINESS_READER_PORT) private readonly reader: BusinessReaderPort,
  ) {}

  async execute(
    rawMunicipalityId: string,
  ): Promise<Result<BusinessCategory[]>> {
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
