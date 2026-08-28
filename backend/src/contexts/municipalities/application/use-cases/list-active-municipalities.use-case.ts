import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { Municipality } from '../../domain/entities/municipality.entity';
import { MUNICIPALITY_READER_PORT } from '../../domain/ports/municipality-reader.port';
import type { MunicipalityReaderPort } from '../../domain/ports/municipality-reader.port';

@Injectable()
export class ListActiveMunicipalitiesUseCase {
  constructor(
    @Inject(MUNICIPALITY_READER_PORT)
    private readonly reader: MunicipalityReaderPort,
  ) {}

  async execute(): Promise<Result<Municipality[]>> {
    const municipalities = await this.reader.findAllActive();
    return Result.success(municipalities);
  }
}
