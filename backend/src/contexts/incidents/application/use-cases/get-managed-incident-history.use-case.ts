import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { IncidentStatusChange } from '../../domain/entities/incident-status-change.entity';
import {
  IncidentForbiddenError,
  IncidentNotFoundError,
} from '../../domain/errors/incident-errors';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type { IncidentReaderPort } from '../../domain/ports/incident-reader.port';

export interface GetManagedIncidentHistoryInput {
  incidentId: string;
  managerId: string;
}

@Injectable()
export class GetManagedIncidentHistoryUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(
    input: GetManagedIncidentHistoryInput,
  ): Promise<Result<IncidentStatusChange[]>> {
    const incident = await this.reader.findById(input.incidentId);
    if (!incident) {
      return Result.failure(new IncidentNotFoundError(input.incidentId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      incident.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new IncidentForbiddenError(
          input.managerId,
          incident.municipalityId.value,
        ),
      );
    }

    const history = await this.reader.findStatusHistory(input.incidentId);
    return Result.success(history);
  }
}
