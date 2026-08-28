import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { EventCategory } from '../value-objects/event-category.vo';

export interface EventProps {
  id: string;
  municipalityId: MunicipalityId;
  title: LocalizedText;
  description: LocalizedText;
  startAt: Date;
  endAt: Date | null;
  locationName: string | null;
  lat: number | null;
  lng: number | null;
  category: EventCategory;
}

export class MunicipalEvent {
  private constructor(private readonly props: EventProps) {}

  static create(props: EventProps): MunicipalEvent {
    // Un evento que acaba antes de empezar no llega a existir.
    if (props.endAt && props.endAt.getTime() < props.startAt.getTime()) {
      throw new ValidationError('Event endAt must not precede startAt');
    }
    // Coordenadas: o van las dos o no va ninguna — media coordenada no ubica
    // nada en un mapa.
    if ((props.lat === null) !== (props.lng === null)) {
      throw new ValidationError('Event requires both lat and lng, or neither');
    }
    return new MunicipalEvent(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get title(): LocalizedText {
    return this.props.title;
  }

  get description(): LocalizedText {
    return this.props.description;
  }

  get startAt(): Date {
    return this.props.startAt;
  }

  get endAt(): Date | null {
    return this.props.endAt;
  }

  get locationName(): string | null {
    return this.props.locationName;
  }

  get lat(): number | null {
    return this.props.lat;
  }

  get lng(): number | null {
    return this.props.lng;
  }

  get category(): EventCategory {
    return this.props.category;
  }

  // Un recordatorio solo tiene sentido antes del comienzo del evento.
  acceptsReminderAt(remindAt: Date): boolean {
    return remindAt.getTime() < this.props.startAt.getTime();
  }
}
