import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Facility } from '../../domain/entities/facility.entity';
import { FACILITY_READER_PORT } from '../../domain/ports/facility-reader.port';
import type { FacilityReaderPort } from '../../domain/ports/facility-reader.port';

export interface ListFacilitiesInput {
  municipalityId: string;
  category?: string;
  // Solo el gestor puede ver las instalaciones desactivadas.
  onlyActive: boolean;
}

@Injectable()
export class ListFacilitiesUseCase {
  constructor(
    @Inject(FACILITY_READER_PORT) private readonly reader: FacilityReaderPort,
  ) {}

  async execute(input: ListFacilitiesInput): Promise<Result<Facility[]>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const facilities = await this.reader.find({
      municipalityId,
      category: input.category,
      onlyActive: input.onlyActive,
    });
    return Result.success(facilities);
  }
}
