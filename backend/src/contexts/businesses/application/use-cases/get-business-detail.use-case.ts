import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../../domain/entities/business.entity';
import { BusinessNotFoundError } from '../../domain/errors/business-errors';
import { BUSINESS_READER_PORT } from '../../domain/ports/business-reader.port';
import type { BusinessReaderPort } from '../../domain/ports/business-reader.port';

@Injectable()
export class GetBusinessDetailUseCase {
  constructor(
    @Inject(BUSINESS_READER_PORT) private readonly reader: BusinessReaderPort,
  ) {}

  // El municipio es obligatorio: el aislamiento entre municipios se verifica
  // aquí, no solo en el controlador. Un comercio de otro pueblo se responde
  // como NO ENCONTRADO, no como prohibido.
  async execute(
    id: string,
    rawMunicipalityId: string,
  ): Promise<Result<Business>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const business = await this.reader.findByIdPublished(id, municipalityId);
    if (!business) {
      return Result.failure(new BusinessNotFoundError(id));
    }
    return Result.success(business);
  }
}
