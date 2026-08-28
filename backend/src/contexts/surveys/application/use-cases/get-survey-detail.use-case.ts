import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Survey } from '../../domain/entities/survey.entity';
import { SurveyNotFoundError } from '../../domain/errors/survey-errors';
import { SURVEY_READER_PORT } from '../../domain/ports/survey-reader.port';
import type {
  SurveyOptionTally,
  SurveyReaderPort,
} from '../../domain/ports/survey-reader.port';

export interface SurveyDetail {
  survey: Survey;
  // Null cuando los resultados aún no son visibles: no se filtra el recuento
  // por la puerta de atrás.
  tallies: SurveyOptionTally[] | null;
  votedOptionId: string | null;
}

@Injectable()
export class GetSurveyDetailUseCase {
  constructor(
    @Inject(SURVEY_READER_PORT) private readonly reader: SurveyReaderPort,
  ) {}

  async execute(
    id: string,
    rawMunicipalityId: string,
    rawDeviceId: string | undefined,
  ): Promise<Result<SurveyDetail>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const survey = await this.reader.findByIdForMunicipality(
      id,
      municipalityId,
    );
    if (!survey) {
      return Result.failure(new SurveyNotFoundError(id));
    }

    // El dispositivo es opcional aquí: consultar una encuesta no es escribir,
    // así que un X-Device-Id ausente o mal formado no bloquea la lectura.
    let votedOptionId: string | null = null;
    if (rawDeviceId) {
      try {
        const deviceId = DeviceId.create(rawDeviceId);
        const vote = await this.reader.findDeviceVote(id, deviceId);
        votedOptionId = vote?.optionId ?? null;
      } catch {
        votedOptionId = null;
      }
    }

    const now = new Date();
    const tallies = survey.areResultsVisibleAt(now)
      ? await this.reader.countVotesByOption(id)
      : null;

    return Result.success({ survey, tallies, votedOptionId });
  }
}
