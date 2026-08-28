import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { Facility } from '../../domain/entities/facility.entity';
import {
  FacilityInactiveError,
  FacilityNotFoundError,
} from '../../domain/errors/facility-errors';
import { FACILITY_READER_PORT } from '../../domain/ports/facility-reader.port';
import type { FacilityReaderPort } from '../../domain/ports/facility-reader.port';

@Injectable()
export class GetFacilityUseCase {
  constructor(
    @Inject(FACILITY_READER_PORT)
    private readonly facilities: FacilityReaderPort,
  ) {}

  async execute(id: string): Promise<Result<Facility>> {
    const facility = await this.facilities.findById(id);
    if (!facility) {
      return Result.failure(new FacilityNotFoundError(id));
    }
    if (!facility.active) {
      return Result.failure(new FacilityInactiveError(facility.id));
    }
    return Result.success(facility);
  }
}
