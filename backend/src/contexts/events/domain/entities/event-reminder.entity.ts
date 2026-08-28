import { DeviceId } from '../../../../shared/domain/value-objects/device-id';

export interface EventReminderProps {
  id: string;
  eventId: string;
  deviceId: DeviceId;
  remindAt: Date;
  sentAt: Date | null;
}

export class EventReminder {
  private constructor(private readonly props: EventReminderProps) {}

  static create(props: EventReminderProps): EventReminder {
    return new EventReminder(props);
  }

  get id(): string {
    return this.props.id;
  }

  get eventId(): string {
    return this.props.eventId;
  }

  get deviceId(): DeviceId {
    return this.props.deviceId;
  }

  get remindAt(): Date {
    return this.props.remindAt;
  }

  get sentAt(): Date | null {
    return this.props.sentAt;
  }
}
