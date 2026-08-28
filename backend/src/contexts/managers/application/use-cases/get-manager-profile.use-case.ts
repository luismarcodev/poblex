import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Municipality } from '../../../municipalities/domain/entities/municipality.entity';
import { MUNICIPALITY_READER_PORT } from '../../../municipalities/domain/ports/municipality-reader.port';
import type { MunicipalityReaderPort } from '../../../municipalities/domain/ports/municipality-reader.port';
import { Manager } from '../../domain/entities/manager.entity';
import { MANAGER_REPOSITORY_PORT } from '../../domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../domain/ports/manager-repository.port';

export interface ManagerProfile {
  manager: Manager;
  municipalities: Municipality[];
}

// El backoffice necesita esto nada más entrar: sin saber qué municipios lleva
// el gestor no puede pintar el selector de municipio ni decidir dónde publica.
// `manager_municipalities` es N:M, así que la respuesta es siempre una lista.
@Injectable()
export class GetManagerProfileUseCase {
  constructor(
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    @Inject(MUNICIPALITY_READER_PORT)
    private readonly municipalities: MunicipalityReaderPort,
  ) {}

  async execute(managerId: string): Promise<Result<ManagerProfile>> {
    const manager = await this.managers.findById(managerId);
    if (!manager) {
      // El JWT es válido pero el gestor ya no existe: la cuenta se borró
      // mientras la sesión seguía viva.
      return Result.failure(
        new NotFoundError(`Manager not found: ${managerId}`),
      );
    }

    const ids = await this.managers.findMunicipalityIdsOf(managerId);
    const found = await Promise.all(
      ids.map((id) =>
        this.municipalities.findActiveById(MunicipalityId.create(id)),
      ),
    );

    return Result.success({
      manager,
      // Un municipio desactivado desaparece del selector sin romper la sesión.
      municipalities: found.filter(
        (municipality): municipality is Municipality => municipality !== null,
      ),
    });
  }
}
