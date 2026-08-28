import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Alert } from '../../domain/entities/alert.entity';
import {
  AemetAlertNotEditableError,
  AlertForbiddenError,
  AlertNotFoundError,
} from '../../domain/errors/alert-errors';
import { ALERT_READER_PORT } from '../../domain/ports/alert-reader.port';
import type { AlertReaderPort } from '../../domain/ports/alert-reader.port';

@Injectable()
export class AuthorizeAlertMutationService {
  constructor(
    @Inject(ALERT_READER_PORT) private readonly reader: AlertReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async ensureMutable(
    alertId: string,
    managerId: string,
  ): Promise<Result<Alert>> {
    const existing = await this.reader.findById(alertId);
    if (!existing) {
      return Result.failure(new AlertNotFoundError(alertId));
    }

    // Lo de AEMET es un espejo de la fuente oficial: no se edita a mano.
    if (existing.source.isAemet) {
      return Result.failure(new AemetAlertNotEditableError(alertId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new AlertForbiddenError(managerId, existing.municipalityId.value),
      );
    }

    return Result.success(existing);
  }
}
