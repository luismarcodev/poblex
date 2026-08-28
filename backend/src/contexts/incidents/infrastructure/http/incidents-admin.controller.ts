import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { ChangeIncidentStatusUseCase } from '../../application/use-cases/change-incident-status.use-case';
import { ListManagedIncidentsUseCase } from '../../application/use-cases/list-managed-incidents.use-case';
import { IncidentHttpMapper } from '../mappers/incident-http.mapper';
import {
  IncidentListResponseDto,
  IncidentResponseDto,
} from './dto/incident-response.dto';
import {
  ChangeIncidentStatusDto,
  ListManagedIncidentsQueryDto,
} from './dto/manage-incident.dto';

@ApiTags('incidents-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/incidents')
export class IncidentsAdminController {
  constructor(
    private readonly listManagedIncidents: ListManagedIncidentsUseCase,
    private readonly changeIncidentStatus: ChangeIncidentStatusUseCase,
  ) {}

  @Get()
  async list(
    @CurrentManagerId() managerId: string,
    @Query() query: ListManagedIncidentsQueryDto,
  ): Promise<IncidentListResponseDto> {
    const result = await this.listManagedIncidents.execute({
      managerId,
      municipalityId: query.municipalityId,
      status: query.status,
      category: query.category,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((incident) =>
        IncidentHttpMapper.toResponseDto(incident),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  @Patch(':id/status')
  async changeStatus(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: ChangeIncidentStatusDto,
  ): Promise<IncidentResponseDto> {
    const result = await this.changeIncidentStatus.execute({
      incidentId: id,
      managerId,
      status: dto.status,
      note: dto.note,
    });
    if (result.isFailure) throw result.error;
    return IncidentHttpMapper.toResponseDto(result.value);
  }
}
