import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { CurrentManagerId } from '../../../managers/infrastructure/http/decorators/current-manager-id.decorator';
import { ManagerJwtAuthGuard } from '../../../managers/infrastructure/security/manager-jwt-auth.guard';
import { CreateEventUseCase } from '../../application/use-cases/create-event.use-case';
import { DeleteEventUseCase } from '../../application/use-cases/delete-event.use-case';
import { ListManagedEventsUseCase } from '../../application/use-cases/list-managed-events.use-case';
import { UpdateEventUseCase } from '../../application/use-cases/update-event.use-case';
import { EventHttpMapper } from '../mappers/event-http.mapper';
import { CreateEventDto } from './dto/create-event.dto';
import {
  EventListResponseDto,
  EventResponseDto,
} from './dto/event-response.dto';
import { ListManagedEventsQueryDto } from './dto/list-events-query.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@ApiTags('events-admin')
@ApiBearerAuth()
@UseGuards(ManagerJwtAuthGuard)
@Controller('admin/events')
export class EventsAdminController {
  constructor(
    private readonly createEvent: CreateEventUseCase,
    private readonly updateEvent: UpdateEventUseCase,
    private readonly deleteEvent: DeleteEventUseCase,
    private readonly listEvents: ListManagedEventsUseCase,
  ) {}

  // Vista de gestión: incluye lo ya celebrado, que el listado del vecino oculta.
  @Get()
  async list(
    @CurrentManagerId() managerId: string,
    @Query() query: ListManagedEventsQueryDto,
  ): Promise<EventListResponseDto> {
    const result = await this.listEvents.execute({
      managerId,
      municipalityId: query.municipalityId,
      includePast: query.includePast,
      cursor: query.cursor,
      limit: query.limit,
    });
    if (result.isFailure) throw result.error;

    return {
      items: result.value.items.map((event) =>
        EventHttpMapper.toResponseDto(event),
      ),
      nextCursor: result.value.nextCursor,
    };
  }

  // Un evento POR MUNICIPIO: cada uno con su identificador y sus recordatorios.
  @Post()
  async create(
    @CurrentManagerId() managerId: string,
    @Body() dto: CreateEventDto,
  ): Promise<EventResponseDto[]> {
    const result = await this.createEvent.execute({
      managerId,
      municipalityIds: dto.municipalityIds,
      title: dto.title,
      description: dto.description,
      startAt: dto.startAt,
      endAt: dto.endAt,
      locationName: dto.locationName,
      lat: dto.lat,
      lng: dto.lng,
      category: dto.category,
    });
    if (result.isFailure) throw result.error;
    return result.value.map((event) => EventHttpMapper.toResponseDto(event));
  }

  @Patch(':id')
  async update(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
    @Body() dto: UpdateEventDto,
  ): Promise<EventResponseDto> {
    const result = await this.updateEvent.execute({
      id,
      managerId,
      title: dto.title,
      description: dto.description,
      startAt: dto.startAt,
      endAt: dto.endAt,
      locationName: dto.locationName,
      lat: dto.lat,
      lng: dto.lng,
      category: dto.category,
    });
    if (result.isFailure) throw result.error;
    return EventHttpMapper.toResponseDto(result.value);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(
    @CurrentManagerId() managerId: string,
    @Param('id') id: string,
  ): Promise<void> {
    const result = await this.deleteEvent.execute(id, managerId);
    if (result.isFailure) throw result.error;
  }
}
