import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../shared/domain/errors/common-errors';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Municipality } from '../../domain/entities/municipality.entity';
import { MUNICIPALITY_READER_PORT } from '../../domain/ports/municipality-reader.port';
import type { MunicipalityReaderPort } from '../../domain/ports/municipality-reader.port';

// Usado también por el contexto `devices` para validar que el municipio
// elegido por el vecino existe y está activo antes de dar de alta el dispositivo.
@Injectable()
export class GetActiveMunicipalityByIdUseCase {
  constructor(
    @Inject(MUNICIPALITY_READER_PORT)
    private readonly reader: MunicipalityReaderPort,
  ) {}

  async execute(rawId: string): Promise<Result<Municipality>> {
    let id: MunicipalityId;
    try {
      id = MunicipalityId.create(rawId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const municipality = await this.reader.findActiveById(id);
    if (!municipality) {
      return Result.failure(
        new NotFoundError(`Municipality not found: ${rawId}`),
      );
    }
    return Result.success(municipality);
  }
}
