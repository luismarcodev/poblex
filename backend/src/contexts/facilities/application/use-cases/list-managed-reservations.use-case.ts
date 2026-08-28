import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { RESERVATION_READER_PORT } from '../../domain/ports/reservation-reader.port';
import type {
  ReservationListResult,
  ReservationReaderPort,
} from '../../domain/ports/reservation-reader.port';

export interface ListManagedReservationsInput {
  municipalityId: string;
  facilityId?: string;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListManagedReservationsUseCase {
  constructor(
    @Inject(RESERVATION_READER_PORT)
    private readonly reader: ReservationReaderPort,
  ) {}

  async execute(
    input: ListManagedReservationsInput,
  ): Promise<Result<ReservationListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const result = await this.reader.findManaged({
      municipalityId,
      facilityId: input.facilityId,
      cursor: input.cursor,
      limit: Math.min(input.limit ?? DEFAULT_LIMIT, MAX_LIMIT),
    });
    return Result.success(result);
  }
}
