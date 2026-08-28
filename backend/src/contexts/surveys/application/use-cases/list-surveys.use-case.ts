import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { SURVEY_READER_PORT } from '../../domain/ports/survey-reader.port';
import type {
  SurveyListResult,
  SurveyReaderPort,
} from '../../domain/ports/survey-reader.port';

export interface ListSurveysInput {
  municipalityId: string;
  includeClosed?: boolean;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListSurveysUseCase {
  constructor(
    @Inject(SURVEY_READER_PORT) private readonly reader: SurveyReaderPort,
  ) {}

  async execute(input: ListSurveysInput): Promise<Result<SurveyListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const result = await this.reader.find({
      municipalityId,
      openAt: input.includeClosed ? undefined : new Date(),
      cursor: input.cursor,
      limit:
        input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
          ? input.limit
          : DEFAULT_LIMIT,
    });
    return Result.success(result);
  }
}
