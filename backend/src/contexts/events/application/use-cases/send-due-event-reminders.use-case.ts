import { Inject, Injectable } from '@nestjs/common';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { NotifyDevicesService } from '../../../devices/application/services/notify-devices.service';
import { EVENT_REMINDER_PORT } from '../../domain/ports/event-reminder.port';
import type {
  DueReminder,
  EventReminderPort,
} from '../../domain/ports/event-reminder.port';

// Tope por ejecución: la tarea corre cada 15 minutos, así que una cola larga
// se drena en varias pasadas en vez de bloquear el proceso en una sola.
const BATCH_LIMIT = 500;

@Injectable()
export class SendDueEventRemindersUseCase {
  constructor(
    @Inject(EVENT_REMINDER_PORT) private readonly reminders: EventReminderPort,
    private readonly notifyDevices: NotifyDevicesService,
  ) {}

  async execute(now: Date = new Date()): Promise<number> {
    const due = await this.reminders.findDue(now, BATCH_LIMIT);
    if (due.length === 0) return 0;

    // Agrupados por evento: un envío por evento, no uno por recordatorio.
    const byEvent = new Map<string, DueReminder[]>();
    for (const reminder of due) {
      const group = byEvent.get(reminder.eventId) ?? [];
      group.push(reminder);
      byEvent.set(reminder.eventId, group);
    }

    for (const [eventId, group] of byEvent) {
      const eventTitle = group[0].eventTitle;
      const deviceIds: DeviceId[] = group.map((reminder) => reminder.deviceId);

      // Dirigido por token, NUNCA por topic: solo lo reciben los dispositivos
      // que pidieron el recordatorio.
      await this.notifyDevices.notify(deviceIds, {
        title: {
          es: 'Recordatorio de evento',
          va: 'Recordatori d’esdeveniment',
        },
        body: {
          es: eventTitle.resolve('es').text,
          va: eventTitle.resolve('va').text,
        },
        data: { type: 'event', id: eventId },
      });
    }

    await this.reminders.markSent(
      due.map((reminder) => reminder.id),
      now,
    );
    return due.length;
  }
}
