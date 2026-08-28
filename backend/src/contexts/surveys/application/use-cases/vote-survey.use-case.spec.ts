import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { Device } from '../../../devices/domain/entities/device.entity';
import type { DeviceReaderPort } from '../../../devices/domain/ports/device-reader.port';
import { Survey, SurveyOption } from '../../domain/entities/survey.entity';
import {
  AlreadyVotedError,
  SurveyClosedError,
  SurveyNotFoundError,
  UnknownSurveyOptionError,
} from '../../domain/errors/survey-errors';
import type { SurveyReaderPort } from '../../domain/ports/survey-reader.port';
import type {
  CastVoteParams,
  SurveyWriterPort,
} from '../../domain/ports/survey-writer.port';
import { VoteSurveyUseCase } from './vote-survey.use-case';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';
const DEVICE_ID = '7c9e6679-7425-40de-944b-e07fc1f90ae7';

function buildSurvey(closesAt: Date): Survey {
  return Survey.create({
    id: 'survey-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    question: LocalizedText.create({ es: '¿Paella en la plaza?' }),
    closesAt,
    resultsVisible: false,
    options: [
      SurveyOption.create({
        id: 'option-yes',
        label: LocalizedText.create({ es: 'Sí' }),
        position: 0,
      }),
      SurveyOption.create({
        id: 'option-no',
        label: LocalizedText.create({ es: 'No' }),
        position: 1,
      }),
    ],
  });
}

interface Harness {
  useCase: VoteSurveyUseCase;
  castVote: jest.Mock<Promise<boolean>, [CastVoteParams]>;
}

function buildHarness(options: {
  survey: Survey | null;
  deviceExists?: boolean;
  voteAccepted?: boolean;
}): Harness {
  const reader = {
    findById: jest.fn().mockResolvedValue(options.survey),
  } as unknown as SurveyReaderPort;

  const castVote = jest
    .fn<Promise<boolean>, [CastVoteParams]>()
    .mockResolvedValue(options.voteAccepted ?? true);
  const writer = { castVote } as unknown as SurveyWriterPort;

  const devices = {
    findRegisteredAndTouch: jest.fn().mockResolvedValue(
      options.deviceExists === false
        ? null
        : Device.create({
            id: DeviceId.create(DEVICE_ID),
            municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
            locale: 'es',
            fcmToken: null,
            lastSeenAt: new Date(),
          }),
    ),
  } as unknown as DeviceReaderPort;

  return {
    useCase: new VoteSurveyUseCase(
      reader,
      writer,
      new RequireRegisteredDeviceService(devices),
    ),
    castVote,
  };
}

const OPEN_UNTIL = new Date(Date.now() + 86_400_000);
const CLOSED_SINCE = new Date(Date.now() - 86_400_000);

describe('VoteSurveyUseCase', () => {
  it('records the vote of a registered device on an open survey', async () => {
    const { useCase, castVote } = buildHarness({
      survey: buildSurvey(OPEN_UNTIL),
    });

    const result = await useCase.execute({
      surveyId: 'survey-1',
      optionId: 'option-yes',
      deviceId: DEVICE_ID,
    });

    expect(result.isSuccess).toBe(true);
    expect(castVote).toHaveBeenCalledTimes(1);
  });

  // Alta de dispositivo obligatoria antes de cualquier escritura.
  it('refuses a device that was never registered', async () => {
    const { useCase, castVote } = buildHarness({
      survey: buildSurvey(OPEN_UNTIL),
      deviceExists: false,
    });

    const result = await useCase.execute({
      surveyId: 'survey-1',
      optionId: 'option-yes',
      deviceId: DEVICE_ID,
    });

    expect(result.isFailure).toBe(true);
    expect(castVote).not.toHaveBeenCalled();
  });

  it('refuses a malformed device id without hitting the database', async () => {
    const { useCase, castVote } = buildHarness({
      survey: buildSurvey(OPEN_UNTIL),
    });

    const result = await useCase.execute({
      surveyId: 'survey-1',
      optionId: 'option-yes',
      deviceId: 'not-a-uuid',
    });

    expect(result.isFailure).toBe(true);
    expect(castVote).not.toHaveBeenCalled();
  });

  it('fails when the survey does not exist', async () => {
    const { useCase } = buildHarness({ survey: null });

    const result = await useCase.execute({
      surveyId: 'missing',
      optionId: 'option-yes',
      deviceId: DEVICE_ID,
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      SurveyNotFoundError,
    );
  });

  it('hides a survey that belongs to another municipality', async () => {
    const foreignSurvey = Survey.create({
      id: 'survey-foreign',
      municipalityId: MunicipalityId.create(
        '0f8fad5b-d9cb-469f-a165-70867728950e',
      ),
      question: LocalizedText.create({ es: 'Encuesta ajena' }),
      closesAt: OPEN_UNTIL,
      resultsVisible: false,
      options: [
        SurveyOption.create({
          id: 'option-foreign',
          label: LocalizedText.create({ es: 'Sí' }),
          position: 0,
        }),
        SurveyOption.create({
          id: 'option-foreign-no',
          label: LocalizedText.create({ es: 'No' }),
          position: 1,
        }),
      ],
    });
    const { useCase, castVote } = buildHarness({ survey: foreignSurvey });

    const result = await useCase.execute({
      surveyId: foreignSurvey.id,
      optionId: 'option-foreign',
      deviceId: DEVICE_ID,
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      SurveyNotFoundError,
    );
    expect(castVote).not.toHaveBeenCalled();
  });

  it('refuses a vote on a closed survey', async () => {
    const { useCase, castVote } = buildHarness({
      survey: buildSurvey(CLOSED_SINCE),
    });

    const result = await useCase.execute({
      surveyId: 'survey-1',
      optionId: 'option-yes',
      deviceId: DEVICE_ID,
    });

    expect(result.isFailure && result.error).toBeInstanceOf(SurveyClosedError);
    expect(castVote).not.toHaveBeenCalled();
  });

  it('refuses an option that belongs to another survey', async () => {
    const { useCase } = buildHarness({ survey: buildSurvey(OPEN_UNTIL) });

    const result = await useCase.execute({
      surveyId: 'survey-1',
      optionId: 'option-from-elsewhere',
      deviceId: DEVICE_ID,
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      UnknownSurveyOptionError,
    );
  });

  // La garantía real del voto único es la restricción UNIQUE; el caso de uso
  // traduce ese rechazo a un error de dominio.
  it('reports a duplicate vote rejected by the database', async () => {
    const { useCase } = buildHarness({
      survey: buildSurvey(OPEN_UNTIL),
      voteAccepted: false,
    });

    const result = await useCase.execute({
      surveyId: 'survey-1',
      optionId: 'option-yes',
      deviceId: DEVICE_ID,
    });

    expect(result.isFailure && result.error).toBeInstanceOf(AlreadyVotedError);
  });
});
