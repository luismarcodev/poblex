import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Survey } from '../entities/survey.entity';

export interface CreateSurveyOptionParams {
  label: LocalizedText;
  position: number;
}

export interface CreateSurveyParams {
  municipalityId: MunicipalityId;
  question: LocalizedText;
  closesAt: Date;
  resultsVisible: boolean;
  options: CreateSurveyOptionParams[];
}

export interface CastVoteParams {
  surveyId: string;
  optionId: string;
  deviceId: DeviceId;
}

export interface SurveyWriterPort {
  create(params: CreateSurveyParams): Promise<Survey>;
  close(id: string, closesAt: Date): Promise<Survey>;
  setResultsVisible(id: string, visible: boolean): Promise<Survey>;
  delete(id: string): Promise<void>;

  // Devuelve false si la restricción UNIQUE (survey_id, device_id) rechaza el
  // voto: el dispositivo ya votó. La base de datos es la garantía, no el
  // control previo en memoria.
  castVote(params: CastVoteParams): Promise<boolean>;
}

export const SURVEY_WRITER_PORT = Symbol('SURVEY_WRITER_PORT');
