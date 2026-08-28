import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { IncidentStatus } from '../value-objects/incident-status.vo';

// Requisito legal: la foto de una incidencia se conserva 12 meses tras el
// cierre y después se borra. No es una mejora, es obligación.
export const PHOTO_RETENTION_DAYS = 365;

const MAX_DESCRIPTION_LENGTH = 2000;

export interface IncidentProps {
  id: string;
  municipalityId: MunicipalityId;
  deviceId: DeviceId;
  category: string;
  description: string;
  photoUrl: string | null;
  photoPurgeAt: Date | null;
  lat: number | null;
  lng: number | null;
  status: IncidentStatus;
  createdAt: Date;
  updatedAt: Date;
}

export class Incident {
  private constructor(private readonly props: IncidentProps) {}

  static create(props: IncidentProps): Incident {
    const description = props.description.trim();
    if (description.length === 0) {
      throw new ValidationError('Incident description must not be empty');
    }
    if (description.length > MAX_DESCRIPTION_LENGTH) {
      throw new ValidationError(
        `Incident description exceeds ${MAX_DESCRIPTION_LENGTH} characters`,
      );
    }
    if ((props.lat === null) !== (props.lng === null)) {
      throw new ValidationError(
        'Incident requires both lat and lng, or neither',
      );
    }
    return new Incident({ ...props, description });
  }

  // Momento en que la foto debe purgarse si la incidencia pasa a resuelta en
  // este instante. Null si no hay foto que purgar.
  photoPurgeDateFor(resolvedAt: Date): Date | null {
    if (!this.props.photoUrl) return null;
    return new Date(resolvedAt.getTime() + PHOTO_RETENTION_DAYS * 86_400_000);
  }

  belongsToDevice(deviceId: DeviceId): boolean {
    return this.props.deviceId.equals(deviceId);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get deviceId(): DeviceId {
    return this.props.deviceId;
  }

  get category(): string {
    return this.props.category;
  }

  get description(): string {
    return this.props.description;
  }

  get photoUrl(): string | null {
    return this.props.photoUrl;
  }

  get photoPurgeAt(): Date | null {
    return this.props.photoPurgeAt;
  }

  get lat(): number | null {
    return this.props.lat;
  }

  get lng(): number | null {
    return this.props.lng;
  }

  get status(): IncidentStatus {
    return this.props.status;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get updatedAt(): Date {
    return this.props.updatedAt;
  }
}
