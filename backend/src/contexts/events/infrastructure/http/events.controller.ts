import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { DeviceIdHeader } from '../../../../shared/infrastructure/http/decorators/device-id.decorator';
import { CancelEventReminderUseCase } from '../../application/use-cases/cancel-event-reminder.use-case';
import { GetEventDetailUseCase } from '../../application/use-cases/get-event-detail.use-case';
import { ListUpcomingEventsUseCase } from '../../application/use-cases/list-upcoming-events.use-case';
import { SetEventReminderUseCase } from '../../application/use-cases/set-event-reminder.use-case';
import { EventHttpMapper } from '../mappers/event-http.mapper';
import {
  EventListResponseDto,
  EventResponseDto,
} from './dto/event-response.dto';
import {
  EventDetailQueryDto,
  ListEventsQueryDto,
} from './dto/list-events-query.dto';
import { ReminderResponseDto, SetReminderDto } from './dto/set-reminder.dto';

@ApiTags('events')
@Controller('events')
export class EventsController {
  constructor(
    private readonly listUpcomingEvents: ListUpcomingEventsUseCase,
    private readonly getEventDetail: GetEventDetailUseCase,
    private readonly setEventReminder: SetEventReminderUseCase,
    private readonly cancelEventReminder: CancelEventReminderUseCase,
  ) {}

  @Get()
  async list(
    @Query() query: ListEventsQueryDto,
  ): Promise<EventListResponseDto> {
    const result = await this.listUpcomingEvents.execute({
      municipalityId: query.municipalityId,
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

  @Get(':id')
  async detail(
    @Param('id') id: string,
    @Query() query: EventDetailQueryDto,
  ): Promise<EventResponseDto> {
    const result = await this.getEventDetail.execute(id, query.municipalityId);
    if (result.isFailure) throw result.error;
    return EventHttpMapper.toResponseDto(result.value);
  }

  // Escritura pública: el X-Device-Id es falsificable, así que el endpoint
  // lleva límite por IP además de la restricción UNIQUE de la tabla.
  @Throttle({ default: { limit: 30, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  @Post(':id/reminder')
  async setReminder(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
    @Body() dto: SetReminderDto,
  ): Promise<ReminderResponseDto> {
    const result = await this.setEventReminder.execute({
      eventId: id,
      deviceId,
      remindAt: dto.remindAt,
    });
    if (result.isFailure) throw result.error;

    return {
      eventId: result.value.eventId,
      remindAt: result.value.remindAt.toISOString(),
    };
  }

  @Throttle({ default: { limit: 30, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  @Delete(':id/reminder')
  @HttpCode(HttpStatus.NO_CONTENT)
  async cancelReminder(
    @Param('id') id: string,
    @DeviceIdHeader() deviceId: string | undefined,
  ): Promise<void> {
    const result = await this.cancelEventReminder.execute(id, deviceId);
    if (result.isFailure) throw result.error;
  }
}
