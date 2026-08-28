import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Survey } from '../entities/survey.entity';

export interface FindSurveysParams {
  municipalityId: MunicipalityId;
  // Solo abiertas en este instante, o todas.
  openAt?: Date;
  cursor?: string;
  limit: number;
}

export interface SurveyListResult {
  items: Survey[];
  nextCursor: string | null;
}

export interface SurveyOptionTally {
  optionId: string;
  votes: number;
}

export interface SurveyReaderPort {
  find(params: FindSurveysParams): Promise<SurveyListResult>;
  findById(id: string): Promise<Survey | null>;
  findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Survey | null>;
  countVotesByOption(surveyId: string): Promise<SurveyOptionTally[]>;
  findDeviceVote(
    surveyId: string,
    deviceId: DeviceId,
  ): Promise<{ optionId: string } | null>;
}

export const SURVEY_READER_PORT = Symbol('SURVEY_READER_PORT');
