import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { IncidentForbiddenError } from '../../domain/errors/incident-errors';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type { IncidentReaderPort } from '../../domain/ports/incident-reader.port';

export interface ListIncidentCategoriesInput {
  municipalityId: string;
  managerId: string;
}

// Alimenta el filtro de categoría del backoffice con las que ya existen en
// el municipio, para que el gestor no cree variantes accidentales de una
// etiqueta abierta ("Sanitaria" / "sanitaria").
@Injectable()
export class ListIncidentCategoriesUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: ListIncidentCategoriesInput): Promise<Result<string[]>> {
    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      input.municipalityId,
    );
    if (!isAuthorized) {
      return Result.failure(
        new IncidentForbiddenError(input.managerId, input.municipalityId),
      );
    }

    const categories = await this.reader.findCategories(
      MunicipalityId.create(input.municipalityId),
    );
    return Result.success(categories);
  }
}
