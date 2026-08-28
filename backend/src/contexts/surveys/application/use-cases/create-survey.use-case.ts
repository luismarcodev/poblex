import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Survey, SurveyOption } from '../../domain/entities/survey.entity';
import { SurveyForbiddenError } from '../../domain/errors/survey-errors';
import { SURVEY_WRITER_PORT } from '../../domain/ports/survey-writer.port';
import type {
  CreateSurveyOptionParams,
  SurveyWriterPort,
} from '../../domain/ports/survey-writer.port';

export interface CreateSurveyInput {
  managerId: string;
  municipalityId: string;
  question: { es?: string; va?: string };
  closesAt: Date;
  resultsVisible?: boolean;
  options: Array<{ es?: string; va?: string }>;
}

@Injectable()
export class CreateSurveyUseCase {
  constructor(
    @Inject(SURVEY_WRITER_PORT) private readonly writer: SurveyWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: CreateSurveyInput): Promise<Result<Survey>> {
    let municipalityId: MunicipalityId;
    let question: LocalizedText;
    let options: CreateSurveyOptionParams[];
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      question = LocalizedText.create(input.question);
      options = input.options.map((label, index) => ({
        label: LocalizedText.create(label),
        position: index,
      }));

      // Invariante de la entidad (mínimo de opciones) antes de escribir.
      Survey.create({
        id: 'pending',
        municipalityId,
        question,
        closesAt: input.closesAt,
        resultsVisible: input.resultsVisible ?? true,
        options: options.map((option, index) =>
          SurveyOption.create({
            id: `pending-${index}`,
            label: option.label,
            position: option.position,
          }),
        ),
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new SurveyForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const survey = await this.writer.create({
      municipalityId,
      question,
      closesAt: input.closesAt,
      resultsVisible: input.resultsVisible ?? true,
      options,
    });
    return Result.success(survey);
  }
}
