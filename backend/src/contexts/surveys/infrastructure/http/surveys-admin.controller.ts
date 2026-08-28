import {
  Body,
  Controller,
  Delete,
  Get,
  Header,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiProduces, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { CreateSurveyUseCase } from '../../application/use-cases/create-survey.use-case';
import {
  CloseSurveyUseCase,
  DeleteSurveyUseCase,
  ExportSurveyResultsUseCase,
  SetSurveyResultsVisibilityUseCase,
} from '../../application/use-cases/manage-survey.use-cases';
import { SurveyHttpMapper } from '../mappers/survey-http.mapper';
import {
  CreateSurveyDto,
  SetResultsVisibilityDto,
} from './dto/survey-request.dto';
import { SurveyResponseDto } from './dto/survey-response.dto';

@ApiTags('surveys-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/surveys')
export class SurveysAdminController {
  constructor(
    private readonly createSurvey: CreateSurveyUseCase,
    private readonly closeSurvey: CloseSurveyUseCase,
    private readonly setResultsVisibility: SetSurveyResultsVisibilityUseCase,
    private readonly deleteSurvey: DeleteSurveyUseCase,
    private readonly exportResults: ExportSurveyResultsUseCase,
  ) {}

  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateSurveyDto,
  ): Promise<SurveyResponseDto> {
    const result = await this.createSurvey.execute({
      managerId,
      municipalityId: dto.municipalityId,
      question: dto.question,
      closesAt: dto.closesAt,
      resultsVisible: dto.resultsVisible,
      options: dto.options,
    });
    if (result.isFailure) throw result.error;
    return SurveyHttpMapper.toResponseDto(result.value, null, null);
  }

  @Patch(':id/close')
  async close(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<SurveyResponseDto> {
    const result = await this.closeSurvey.execute(id, managerId);
    if (result.isFailure) throw result.error;
    return SurveyHttpMapper.toResponseDto(result.value, null, null);
  }

  @Patch(':id/results-visibility')
  async setVisibility(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: SetResultsVisibilityDto,
  ): Promise<SurveyResponseDto> {
    const result = await this.setResultsVisibility.execute(
      id,
      managerId,
      dto.visible,
    );
    if (result.isFailure) throw result.error;
    return SurveyHttpMapper.toResponseDto(result.value, null, null);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.deleteSurvey.execute(id, managerId);
    if (result.isFailure) throw result.error;
  }

  @ApiProduces('text/csv')
  @Header('Content-Type', 'text/csv; charset=utf-8')
  @Header('Content-Disposition', 'attachment; filename="resultados.csv"')
  @Get(':id/results.csv')
  async exportCsv(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<string> {
    const result = await this.exportResults.execute(id, managerId);
    if (result.isFailure) throw result.error;
    return result.value;
  }
}
