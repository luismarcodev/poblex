import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Survey } from '../../domain/entities/survey.entity';
import {
  SurveyForbiddenError,
  SurveyNotFoundError,
} from '../../domain/errors/survey-errors';
import { SURVEY_READER_PORT } from '../../domain/ports/survey-reader.port';
import type { SurveyReaderPort } from '../../domain/ports/survey-reader.port';

@Injectable()
export class AuthorizeSurveyMutationService {
  constructor(
    @Inject(SURVEY_READER_PORT) private readonly reader: SurveyReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async ensureMutable(
    surveyId: string,
    managerId: string,
  ): Promise<Result<Survey>> {
    const existing = await this.reader.findById(surveyId);
    if (!existing) {
      return Result.failure(new SurveyNotFoundError(surveyId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new SurveyForbiddenError(managerId, existing.municipalityId.value),
      );
    }

    return Result.success(existing);
  }
}
