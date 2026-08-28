import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { EventReminder } from '../entities/event-reminder.entity';

export interface SetReminderParams {
  eventId: string;
  deviceId: DeviceId;
  remindAt: Date;
}

// Recordatorio vencido listo para enviar, con lo mínimo del evento para
// componer el push: el envío es DIRIGIDO por token, así que necesita el texto
// bilingüe para resolverlo con el idioma de cada dispositivo.
export interface DueReminder {
  id: string;
  eventId: string;
  deviceId: DeviceId;
  eventTitle: LocalizedText;
  eventStartAt: Date;
}

export interface EventReminderPort {
  // UNIQUE (event_id, device_id): reprogramar sustituye, no duplica.
  set(params: SetReminderParams): Promise<EventReminder>;
  cancel(eventId: string, deviceId: DeviceId): Promise<void>;
  findByEventAndDevice(
    eventId: string,
    deviceId: DeviceId,
  ): Promise<EventReminder | null>;
  findDue(now: Date, limit: number): Promise<DueReminder[]>;
  markSent(ids: string[], sentAt: Date): Promise<void>;
}

export const EVENT_REMINDER_PORT = Symbol('EVENT_REMINDER_PORT');
