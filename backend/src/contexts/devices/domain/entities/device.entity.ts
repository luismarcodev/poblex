import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';

export interface DeviceProps {
  id: DeviceId;
  municipalityId: MunicipalityId;
  locale: string;
  fcmToken: string | null;
  lastSeenAt: Date;
}

export class Device {
  private constructor(private readonly props: DeviceProps) {}

  static create(props: DeviceProps): Device {
    return new Device(props);
  }

  get id(): DeviceId {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get locale(): string {
    return this.props.locale;
  }

  get fcmToken(): string | null {
    return this.props.fcmToken;
  }

  get lastSeenAt(): Date {
    return this.props.lastSeenAt;
  }
}
