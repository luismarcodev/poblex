import { Module } from '@nestjs/common';
import { DevicesModule } from '../devices/devices.module';
import { ManagersModule } from '../managers/managers.module';
import { AuthorizeSurveyMutationService } from './application/services/authorize-survey-mutation.service';
import { CreateSurveyUseCase } from './application/use-cases/create-survey.use-case';
import { GetSurveyDetailUseCase } from './application/use-cases/get-survey-detail.use-case';
import { ListSurveysUseCase } from './application/use-cases/list-surveys.use-case';
import {
  CloseSurveyUseCase,
  DeleteSurveyUseCase,
  ExportSurveyResultsUseCase,
  SetSurveyResultsVisibilityUseCase,
} from './application/use-cases/manage-survey.use-cases';
import { VoteSurveyUseCase } from './application/use-cases/vote-survey.use-case';
import { SURVEY_READER_PORT } from './domain/ports/survey-reader.port';
import { SURVEY_WRITER_PORT } from './domain/ports/survey-writer.port';
import { SurveysAdminController } from './infrastructure/http/surveys-admin.controller';
import { SurveysController } from './infrastructure/http/surveys.controller';
import { SurveyPrismaRepository } from './infrastructure/persistence/prisma/survey-prisma.repository';

@Module({
  imports: [ManagersModule, DevicesModule],
  controllers: [SurveysController, SurveysAdminController],
  providers: [
    ListSurveysUseCase,
    GetSurveyDetailUseCase,
    VoteSurveyUseCase,
    CreateSurveyUseCase,
    CloseSurveyUseCase,
    SetSurveyResultsVisibilityUseCase,
    DeleteSurveyUseCase,
    ExportSurveyResultsUseCase,
    AuthorizeSurveyMutationService,
    SurveyPrismaRepository,
    { provide: SURVEY_READER_PORT, useExisting: SurveyPrismaRepository },
    { provide: SURVEY_WRITER_PORT, useExisting: SurveyPrismaRepository },
  ],
})
export class SurveysModule {}
