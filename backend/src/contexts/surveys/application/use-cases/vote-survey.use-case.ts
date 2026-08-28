import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import {
  AlreadyVotedError,
  SurveyClosedError,
  SurveyNotFoundError,
  UnknownSurveyOptionError,
} from '../../domain/errors/survey-errors';
import { SURVEY_READER_PORT } from '../../domain/ports/survey-reader.port';
import type { SurveyReaderPort } from '../../domain/ports/survey-reader.port';
import { SURVEY_WRITER_PORT } from '../../domain/ports/survey-writer.port';
import type { SurveyWriterPort } from '../../domain/ports/survey-writer.port';

export interface VoteSurveyInput {
  surveyId: string;
  optionId: string;
  deviceId: string | undefined;
}

@Injectable()
export class VoteSurveyUseCase {
  constructor(
    @Inject(SURVEY_READER_PORT) private readonly reader: SurveyReaderPort,
    @Inject(SURVEY_WRITER_PORT) private readonly writer: SurveyWriterPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(input: VoteSurveyInput): Promise<Result<void>> {
    const device = await this.requireDevice.ensure(input.deviceId);
    if (device.isFailure) return Result.failure(device.error);

    const survey = await this.reader.findById(input.surveyId);
    if (!survey || !survey.municipalityId.equals(device.value.municipalityId)) {
      return Result.failure(new SurveyNotFoundError(input.surveyId));
    }

    if (!survey.isOpenAt(new Date())) {
      return Result.failure(new SurveyClosedError(input.surveyId));
    }

    if (!survey.hasOption(input.optionId)) {
      return Result.failure(
        new UnknownSurveyOptionError(input.surveyId, input.optionId),
      );
    }

    // Un voto por dispositivo. La comprobación previa da buen mensaje; la
    // garantía es la restricción UNIQUE, que es lo que resuelve la carrera
    // entre dos peticiones simultáneas del mismo dispositivo.
    const accepted = await this.writer.castVote({
      surveyId: input.surveyId,
      optionId: input.optionId,
      deviceId: device.value.id,
    });
    if (!accepted) {
      return Result.failure(new AlreadyVotedError(input.surveyId));
    }

    return Result.success(undefined);
  }
}
