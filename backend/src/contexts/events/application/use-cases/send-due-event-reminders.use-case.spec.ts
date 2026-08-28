import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { NotifyDevicesService } from '../../../devices/application/services/notify-devices.service';
import type {
  DueReminder,
  EventReminderPort,
} from '../../domain/ports/event-reminder.port';
import { SendDueEventRemindersUseCase } from './send-due-event-reminders.use-case';

const DEVICE_A = '7c9e6679-7425-40de-944b-e07fc1f90ae7';
const DEVICE_B = '1b4e28ba-2fa1-41d3-9a5b-e07fc1f90ae7';
const DEVICE_C = '2c5f39cb-3fb2-42e4-8b6c-f18ad2a01bf8';

function due(id: string, eventId: string, deviceId: string): DueReminder {
  return {
    id,
    eventId,
    deviceId: DeviceId.create(deviceId),
    eventTitle: LocalizedText.create({
      es: `Evento ${eventId}`,
      va: `Esdeveniment ${eventId}`,
    }),
    eventStartAt: new Date('2026-09-12T18:00:00Z'),
  };
}

function buildHarness(reminders: DueReminder[]) {
  const markSent = jest.fn().mockResolvedValue(undefined);
  const port = {
    findDue: jest.fn().mockResolvedValue(reminders),
    markSent,
  } as unknown as EventReminderPort;

  const notify = jest.fn().mockResolvedValue(undefined);
  const notifyDevices = { notify } as unknown as NotifyDevicesService;

  return {
    useCase: new SendDueEventRemindersUseCase(port, notifyDevices),
    notify,
    markSent,
  };
}

describe('SendDueEventRemindersUseCase', () => {
  it('does nothing when there is nothing due', async () => {
    const { useCase, notify, markSent } = buildHarness([]);

    const sent = await useCase.execute();

    expect(sent).toBe(0);
    expect(notify).not.toHaveBeenCalled();
    expect(markSent).not.toHaveBeenCalled();
  });

  // Un envío por evento, no uno por recordatorio.
  it('groups reminders by event into a single notification each', async () => {
    const { useCase, notify } = buildHarness([
      due('r1', 'event-1', DEVICE_A),
      due('r2', 'event-1', DEVICE_B),
      due('r3', 'event-2', DEVICE_C),
    ]);

    const sent = await useCase.execute();

    expect(sent).toBe(3);
    expect(notify).toHaveBeenCalledTimes(2);

    const firstCall = notify.mock.calls[0] as [
      DeviceId[],
      { data: Record<string, string> },
    ];
    expect(firstCall[0].map((device) => device.value)).toEqual([
      DEVICE_A,
      DEVICE_B,
    ]);
    expect(firstCall[1].data).toEqual({ type: 'event', id: 'event-1' });
  });

  it('marks every processed reminder as sent', async () => {
    const { useCase, markSent } = buildHarness([
      due('r1', 'event-1', DEVICE_A),
      due('r2', 'event-2', DEVICE_B),
    ]);

    const now = new Date('2026-09-12T17:00:00Z');
    await useCase.execute(now);

    expect(markSent).toHaveBeenCalledWith(['r1', 'r2'], now);
  });

  it('sends the event title in both languages', async () => {
    const { useCase, notify } = buildHarness([due('r1', 'event-1', DEVICE_A)]);

    await useCase.execute();

    const [, notification] = notify.mock.calls[0] as [
      DeviceId[],
      { body: { es: string; va: string } },
    ];
    expect(notification.body.es).toBe('Evento event-1');
    expect(notification.body.va).toBe('Esdeveniment event-1');
  });
});
