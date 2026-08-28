import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { GetAlertDetailUseCase } from '../../application/use-cases/get-alert-detail.use-case';
import { ListAlertsUseCase } from '../../application/use-cases/list-alerts.use-case';
import { AlertHttpMapper } from '../mappers/alert-http.mapper';
import {
  AlertListResponseDto,
  AlertResponseDto,
} from './dto/alert-response.dto';
import {
  AlertDetailQueryDto,
  ListAlertsQueryDto,
} from './dto/list-alerts-query.dto';

@ApiTags('alerts')
@Controller('alerts')
export class AlertsController {
  constructor(
    private readonly listAlerts: ListAlertsUseCase,
    private readonly getAlertDetail: GetAlertDetailUseCase,
  ) {}

  @Get()
  async list(
    @Query() query: ListAlertsQueryDto,
  ): Promise<AlertListResponseDto> {
    const result = await this.listAlerts.execute({
      municipalityId: query.municipalityId,
      includeExpired: query.includeExpired,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((alert) =>
        AlertHttpMapper.toResponseDto(alert),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @Get(':id')
  async detail(
    @Param('id') id: string,
    @Query() query: AlertDetailQueryDto,
  ): Promise<AlertResponseDto> {
    const result = await this.getAlertDetail.execute(id, query.municipalityId);
    if (result.isFailure) throw result.error;
    return AlertHttpMapper.toResponseDto(result.value);
  }
}
