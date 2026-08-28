import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { DeviceIdHeader } from '../../../../shared/infrastructure/http/decorators/device-id.decorator';
import { DeviceThrottlerGuard } from '../../../../shared/infrastructure/http/device-throttler.guard';
import { GetSurveyDetailUseCase } from '../../application/use-cases/get-survey-detail.use-case';
import { ListSurveysUseCase } from '../../application/use-cases/list-surveys.use-case';
import { VoteSurveyUseCase } from '../../application/use-cases/vote-survey.use-case';
import { SurveyHttpMapper } from '../mappers/survey-http.mapper';
import {
  ListSurveysQueryDto,
  SurveyDetailQueryDto,
  VoteDto,
} from './dto/survey-request.dto';
import {
  SurveyListResponseDto,
  SurveyResponseDto,
} from './dto/survey-response.dto';

@ApiTags('surveys')
@Controller('surveys')
export class SurveysController {
  constructor(
    private readonly listSurveys: ListSurveysUseCase,
    private readonly getSurveyDetail: GetSurveyDetailUseCase,
    private readonly voteSurvey: VoteSurveyUseCase,
  ) {}

  @Get()
  async list(
    @Query() query: ListSurveysQueryDto,
  ): Promise<SurveyListResponseDto> {
    const result = await this.listSurveys.execute({
      municipalityId: query.municipalityId,
      includeClosed: query.includeClosed,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    // El listado no resuelve recuentos ni voto propio: eso es del detalle.
    return {
      items: result.value.items.map((survey) =>
        SurveyHttpMapper.toResponseDto(survey, null, null),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @ApiHeader({ name: 'X-Device-Id', required: false })
  @Get(':id')
  async detail(
    @Param('id') id: string,
    @Query() query: SurveyDetailQueryDto,
    @DeviceIdHeader() deviceId: string | undefined,
  ): Promise<SurveyResponseDto> {
    const result = await this.getSurveyDetail.execute(
      id,
      query.municipalityId,
      deviceId,
    );
    if (result.isFailure) throw result.error;

    return SurveyHttpMapper.toResponseDto(
      result.value.survey,
      result.value.tallies,
      result.value.votedOptionId,
    );
  }

  // La restricción UNIQUE impide el voto duplicado; el límite por IP evita la
  // creación masiva de dispositivos falsos para inflar una votación.
  @UseGuards(DeviceThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  @Post(':id/vote')
  @HttpCode(HttpStatus.NO_CONTENT)
  async vote(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
    @Body() dto: VoteDto,
  ): Promise<void> {
    const result = await this.voteSurvey.execute({
      surveyId: id,
      optionId: dto.optionId,
      deviceId,
    });
    if (result.isFailure) throw result.error;
  }
}
