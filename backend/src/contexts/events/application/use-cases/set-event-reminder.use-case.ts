import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { EventReminder } from '../../domain/entities/event-reminder.entity';
import {
  EventNotFoundError,
  ReminderAfterEventStartError,
} from '../../domain/errors/event-errors';
import { EVENT_READER_PORT } from '../../domain/ports/event-reader.port';
import type { EventReaderPort } from '../../domain/ports/event-reader.port';
import { EVENT_REMINDER_PORT } from '../../domain/ports/event-reminder.port';
import type { EventReminderPort } from '../../domain/ports/event-reminder.port';

export interface SetEventReminderInput {
  eventId: string;
  deviceId: string | undefined;
  remindAt: Date;
}

@Injectable()
export class SetEventReminderUseCase {
  constructor(
    @Inject(EVENT_READER_PORT) private readonly reader: EventReaderPort,
    @Inject(EVENT_REMINDER_PORT) private readonly reminders: EventReminderPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(input: SetEventReminderInput): Promise<Result<EventReminder>> {
    const device = await this.requireDevice.ensure(input.deviceId);
    if (device.isFailure) return Result.failure(device.error);

    const event = await this.reader.findById(input.eventId);
    if (!event || !event.municipalityId.equals(device.value.municipalityId)) {
      return Result.failure(new EventNotFoundError(input.eventId));
    }

    if (!event.acceptsReminderAt(input.remindAt)) {
      return Result.failure(new ReminderAfterEventStartError(input.eventId));
    }

    // UNIQUE (event_id, device_id): reprogramar sustituye el anterior.
    const reminder = await this.reminders.set({
      eventId: input.eventId,
      deviceId: device.value.id,
      remindAt: input.remindAt,
    });
    return Result.success(reminder);
  }
}
