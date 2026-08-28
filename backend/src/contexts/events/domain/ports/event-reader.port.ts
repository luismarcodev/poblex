import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MunicipalEvent } from '../entities/event.entity';

export interface FindUpcomingEventsParams {
  municipalityId: MunicipalityId;
  // Corte inferior: por defecto "ahora". Permite pedir el histórico reciente.
  from: Date;
  cursor?: string;
  limit: number;
}

export interface EventListResult {
  items: MunicipalEvent[];
  nextCursor: string | null;
}

export interface EventReaderPort {
  findUpcoming(params: FindUpcomingEventsParams): Promise<EventListResult>;
  findById(id: string): Promise<MunicipalEvent | null>;
  findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<MunicipalEvent | null>;
}

export const EVENT_READER_PORT = Symbol('EVENT_READER_PORT');
