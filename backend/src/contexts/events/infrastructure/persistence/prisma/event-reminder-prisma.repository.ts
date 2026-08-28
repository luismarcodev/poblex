import { Injectable } from '@nestjs/common';
import { DeviceId } from '../../../../../shared/domain/value-objects/device-id';
import { LocalizedText } from '../../../../../shared/domain/value-objects/localized-text';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { EventReminder } from '../../../domain/entities/event-reminder.entity';
import type {
  DueReminder,
  EventReminderPort,
  SetReminderParams,
} from '../../../domain/ports/event-reminder.port';

interface RawLocalizedJson {
  es?: string;
  va?: string;
}

@Injectable()
export class EventReminderPrismaRepository implements EventReminderPort {
  constructor(private readonly prisma: PrismaService) {}

  async set(params: SetReminderParams): Promise<EventReminder> {
    // Reprogramar limpia `sentAt`: el recordatorio vuelve a estar pendiente.
    const row = await this.prisma.eventReminder.upsert({
      where: {
        eventId_deviceId: {
          eventId: params.eventId,
          deviceId: params.deviceId.value,
        },
      },
      create: {
        eventId: params.eventId,
        deviceId: params.deviceId.value,
        remindAt: params.remindAt,
      },
      update: { remindAt: params.remindAt, sentAt: null },
    });

    return EventReminder.create({
      id: row.id,
      eventId: row.eventId,
      deviceId: DeviceId.create(row.deviceId),
      remindAt: row.remindAt,
      sentAt: row.sentAt,
    });
  }

  async cancel(eventId: string, deviceId: DeviceId): Promise<void> {
    await this.prisma.eventReminder.deleteMany({
      where: { eventId, deviceId: deviceId.value },
    });
  }

  async findByEventAndDevice(
    eventId: string,
    deviceId: DeviceId,
  ): Promise<EventReminder | null> {
    const row = await this.prisma.eventReminder.findUnique({
      where: {
        eventId_deviceId: { eventId, deviceId: deviceId.value },
      },
    });
    if (!row) return null;

    return EventReminder.create({
      id: row.id,
      eventId: row.eventId,
      deviceId: DeviceId.create(row.deviceId),
      remindAt: row.remindAt,
      sentAt: row.sentAt,
    });
  }

  async findDue(now: Date, limit: number): Promise<DueReminder[]> {
    const rows = await this.prisma.eventReminder.findMany({
      where: { remindAt: { lte: now }, sentAt: null },
      include: { event: { select: { title: true, startAt: true } } },
      orderBy: { remindAt: 'asc' },
      take: limit,
    });

    return rows.map((row) => ({
      id: row.id,
      eventId: row.eventId,
      deviceId: DeviceId.create(row.deviceId),
      eventTitle: LocalizedText.create(row.event.title as RawLocalizedJson),
      eventStartAt: row.event.startAt,
    }));
  }

  async markSent(ids: string[], sentAt: Date): Promise<void> {
    if (ids.length === 0) return;
    await this.prisma.eventReminder.updateMany({
      where: { id: { in: ids } },
      data: { sentAt },
    });
  }
}
