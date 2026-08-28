import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { IncidentForbiddenError } from '../../domain/errors/incident-errors';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type {
  IncidentListResult,
  IncidentReaderPort,
} from '../../domain/ports/incident-reader.port';
import { IncidentStatus } from '../../domain/value-objects/incident-status.vo';

export interface ListManagedIncidentsInput {
  managerId: string;
  municipalityId: string;
  status?: string;
  category?: string;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListManagedIncidentsUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(
    input: ListManagedIncidentsInput,
  ): Promise<Result<IncidentListResult>> {
    let municipalityId: MunicipalityId;
    let status: IncidentStatus | undefined;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      status = input.status ? IncidentStatus.create(input.status) : undefined;
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    // El aislamiento entre municipios se verifica en el caso de uso, no solo
    // en el controlador.
    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new IncidentForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const result = await this.reader.findForManager({
      municipalityId,
      status,
      category: input.category,
      cursor: input.cursor,
      limit:
        input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
          ? input.limit
          : DEFAULT_LIMIT,
    });
    return Result.success(result);
  }
}
