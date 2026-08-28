import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { EventNotFoundError } from '../../domain/errors/event-errors';
import { EVENT_READER_PORT } from '../../domain/ports/event-reader.port';
import type { EventReaderPort } from '../../domain/ports/event-reader.port';
import { EVENT_REMINDER_PORT } from '../../domain/ports/event-reminder.port';
import type { EventReminderPort } from '../../domain/ports/event-reminder.port';

@Injectable()
export class CancelEventReminderUseCase {
  constructor(
    @Inject(EVENT_READER_PORT) private readonly reader: EventReaderPort,
    @Inject(EVENT_REMINDER_PORT) private readonly reminders: EventReminderPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(
    eventId: string,
    rawDeviceId: string | undefined,
  ): Promise<Result<void>> {
    const device = await this.requireDevice.ensure(rawDeviceId);
    if (device.isFailure) return Result.failure(device.error);

    const event = await this.reader.findById(eventId);
    if (!event || !event.municipalityId.equals(device.value.municipalityId)) {
      return Result.failure(new EventNotFoundError(eventId));
    }

    // Idempotente: cancelar un recordatorio que no existe no es un error.
    await this.reminders.cancel(eventId, device.value.id);
    return Result.success(undefined);
  }
}
