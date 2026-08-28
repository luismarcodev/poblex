import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { EVENT_READER_PORT } from '../../domain/ports/event-reader.port';
import type {
  EventListResult,
  EventReaderPort,
} from '../../domain/ports/event-reader.port';

export interface ListUpcomingEventsInput {
  municipalityId: string;
  cursor?: string;
  limit?: number;
  // El gestor necesita ver también lo ya celebrado; el vecino, no.
  includePast?: boolean;
  // Los eventos en curso siguen siendo relevantes: el corte no es "startAt >
  // ahora" sino "ahora menos este margen", para que una fiesta que empezó
  // hace dos horas no desaparezca de la agenda.
  from?: Date;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;
const IN_PROGRESS_MARGIN_MS = 6 * 3_600_000;

@Injectable()
export class ListUpcomingEventsUseCase {
  constructor(
    @Inject(EVENT_READER_PORT) private readonly reader: EventReaderPort,
  ) {}

  async execute(
    input: ListUpcomingEventsInput,
  ): Promise<Result<EventListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const limit =
      input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
        ? input.limit
        : DEFAULT_LIMIT;

    const result = await this.reader.findUpcoming({
      municipalityId,
      from: input.includePast
        ? new Date(0)
        : (input.from ?? new Date(Date.now() - IN_PROGRESS_MARGIN_MS)),
      cursor: input.cursor,
      limit,
    });
    return Result.success(result);
  }
}
