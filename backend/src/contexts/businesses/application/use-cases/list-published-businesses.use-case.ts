import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { BUSINESS_READER_PORT } from '../../domain/ports/business-reader.port';
import type {
  BusinessListResult,
  BusinessReaderPort,
} from '../../domain/ports/business-reader.port';
import { BusinessCategory } from '../../domain/value-objects/business-category.vo';

export interface ListPublishedBusinessesInput {
  municipalityId: string;
  category?: string;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListPublishedBusinessesUseCase {
  constructor(
    @Inject(BUSINESS_READER_PORT) private readonly reader: BusinessReaderPort,
  ) {}

  async execute(
    input: ListPublishedBusinessesInput,
  ): Promise<Result<BusinessListResult>> {
    let municipalityId: MunicipalityId;
    let category: BusinessCategory | undefined;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      category = input.category
        ? BusinessCategory.create(input.category)
        : undefined;
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const limit =
      input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
        ? input.limit
        : DEFAULT_LIMIT;

    const result = await this.reader.findPublished({
      municipalityId,
      category,
      cursor: input.cursor,
      limit,
    });
    return Result.success(result);
  }
}
