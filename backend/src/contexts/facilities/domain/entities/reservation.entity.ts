import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';

export interface ReservationProps {
  id: string;
  facilityId: string;
  municipalityId: MunicipalityId;
  deviceId: string;
  slotStart: Date;
  slotEnd: Date;
  createdAt: Date;
}

export class Reservation {
  private constructor(private readonly props: ReservationProps) {}

  static create(props: ReservationProps): Reservation {
    if (props.slotEnd.getTime() <= props.slotStart.getTime()) {
      throw new ValidationError('Reservation slotEnd must be after slotStart');
    }
    return new Reservation(props);
  }

  get id(): string {
    return this.props.id;
  }

  get facilityId(): string {
    return this.props.facilityId;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get deviceId(): string {
    return this.props.deviceId;
  }

  get slotStart(): Date {
    return this.props.slotStart;
  }

  get slotEnd(): Date {
    return this.props.slotEnd;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  isOwnedBy(deviceId: string): boolean {
    return this.props.deviceId === deviceId;
  }
}
