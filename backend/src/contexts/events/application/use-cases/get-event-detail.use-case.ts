import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MunicipalEvent } from '../../domain/entities/event.entity';
import { EventNotFoundError } from '../../domain/errors/event-errors';
import { EVENT_READER_PORT } from '../../domain/ports/event-reader.port';
import type { EventReaderPort } from '../../domain/ports/event-reader.port';

@Injectable()
export class GetEventDetailUseCase {
  constructor(
    @Inject(EVENT_READER_PORT) private readonly reader: EventReaderPort,
  ) {}

  async execute(
    id: string,
    rawMunicipalityId: string,
  ): Promise<Result<MunicipalEvent>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const event = await this.reader.findByIdForMunicipality(id, municipalityId);
    if (!event) {
      return Result.failure(new EventNotFoundError(id));
    }
    return Result.success(event);
  }
}
