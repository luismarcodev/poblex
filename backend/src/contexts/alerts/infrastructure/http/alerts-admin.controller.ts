import {
  Body,
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { CreateManualAlertUseCase } from '../../application/use-cases/create-manual-alert.use-case';
import { DeleteManualAlertUseCase } from '../../application/use-cases/delete-manual-alert.use-case';
import { UpdateManualAlertUseCase } from '../../application/use-cases/update-manual-alert.use-case';
import { AlertHttpMapper } from '../mappers/alert-http.mapper';
import { AlertResponseDto } from './dto/alert-response.dto';
import {
  CreateManualAlertDto,
  UpdateManualAlertDto,
} from './dto/create-manual-alert.dto';

@ApiTags('alerts-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/alerts')
export class AlertsAdminController {
  constructor(
    private readonly createManualAlert: CreateManualAlertUseCase,
    private readonly updateManualAlert: UpdateManualAlertUseCase,
    private readonly deleteManualAlert: DeleteManualAlertUseCase,
  ) {}

  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateManualAlertDto,
  ): Promise<AlertResponseDto> {
    const result = await this.createManualAlert.execute({
      managerId,
      municipalityId: dto.municipalityId,
      severity: dto.severity,
      phenomenonType: dto.phenomenonType,
      phenomenon: dto.phenomenon,
      body: dto.body,
      startAt: dto.startAt,
      endAt: dto.endAt,
    });
    if (result.isFailure) throw result.error;
    return AlertHttpMapper.toResponseDto(result.value);
  }

  @Patch(':id')
  async update(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateManualAlertDto,
  ): Promise<AlertResponseDto> {
    const result = await this.updateManualAlert.execute({
      id,
      managerId,
      severity: dto.severity,
      phenomenonType: dto.phenomenonType,
      phenomenon: dto.phenomenon,
      body: dto.body,
      startAt: dto.startAt,
      endAt: dto.endAt,
    });
    if (result.isFailure) throw result.error;
    return AlertHttpMapper.toResponseDto(result.value);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.deleteManualAlert.execute(id, managerId);
    if (result.isFailure) throw result.error;
  }
}
