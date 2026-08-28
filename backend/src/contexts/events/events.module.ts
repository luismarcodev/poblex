import { Module } from '@nestjs/common';
import { EventRemindersCron } from '../../shared/infrastructure/cron/event-reminders.cron';
import { DevicesModule } from '../devices/devices.module';
import { ManagersModule } from '../managers/managers.module';
import { AuthorizeEventMutationService } from './application/services/authorize-event-mutation.service';
import { CancelEventReminderUseCase } from './application/use-cases/cancel-event-reminder.use-case';
import { CreateEventUseCase } from './application/use-cases/create-event.use-case';
import { DeleteEventUseCase } from './application/use-cases/delete-event.use-case';
import { GetEventDetailUseCase } from './application/use-cases/get-event-detail.use-case';
import { ListUpcomingEventsUseCase } from './application/use-cases/list-upcoming-events.use-case';
import { ListManagedEventsUseCase } from './application/use-cases/list-managed-events.use-case';
import { SendDueEventRemindersUseCase } from './application/use-cases/send-due-event-reminders.use-case';
import { SetEventReminderUseCase } from './application/use-cases/set-event-reminder.use-case';
import { UpdateEventUseCase } from './application/use-cases/update-event.use-case';
import { EVENT_READER_PORT } from './domain/ports/event-reader.port';
import { EVENT_REMINDER_PORT } from './domain/ports/event-reminder.port';
import { EVENT_WRITER_PORT } from './domain/ports/event-writer.port';
import { EventsAdminController } from './infrastructure/http/events-admin.controller';
import { EventsController } from './infrastructure/http/events.controller';
import { EventReminderPrismaRepository } from './infrastructure/persistence/prisma/event-reminder-prisma.repository';
import { EventPrismaRepository } from './infrastructure/persistence/prisma/event-prisma.repository';

@Module({
  imports: [ManagersModule, DevicesModule],
  controllers: [EventsController, EventsAdminController],
  providers: [
    ListUpcomingEventsUseCase,
    ListManagedEventsUseCase,
    GetEventDetailUseCase,
    CreateEventUseCase,
    UpdateEventUseCase,
    DeleteEventUseCase,
    SetEventReminderUseCase,
    CancelEventReminderUseCase,
    SendDueEventRemindersUseCase,
    AuthorizeEventMutationService,
    EventRemindersCron,
    EventPrismaRepository,
    { provide: EVENT_READER_PORT, useExisting: EventPrismaRepository },
    { provide: EVENT_WRITER_PORT, useExisting: EventPrismaRepository },
    {
      provide: EVENT_REMINDER_PORT,
      useClass: EventReminderPrismaRepository,
    },
  ],
})
export class EventsModule {}
