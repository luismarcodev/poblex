import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MunicipalEvent } from '../entities/event.entity';
import { EventCategory } from '../value-objects/event-category.vo';

export interface CreateEventParams {
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

export interface UpdateEventFields {
  title?: LocalizedText;
  description?: LocalizedText;
  startAt?: Date;
  endAt?: Date | null;
  locationName?: string | null;
  lat?: number | null;
  lng?: number | null;
  category?: EventCategory;
}

export interface EventWriterPort {
  create(params: CreateEventParams): Promise<MunicipalEvent>;
  update(id: string, fields: UpdateEventFields): Promise<MunicipalEvent>;
  delete(id: string): Promise<void>;
}

export const EVENT_WRITER_PORT = Symbol('EVENT_WRITER_PORT');
