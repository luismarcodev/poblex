import { Inject, Injectable } from '@nestjs/common';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Result } from '../../../../shared/domain/result';
import {
  BusinessForbiddenError,
  BusinessNotFoundError,
} from '../../domain/errors/business-errors';
import { Business } from '../../domain/entities/business.entity';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';

// Compartido por todos los casos de uso que MUTAN un comercio existente
// (update, active, fotos): comprueba que existe y que el gestor pertenece
// al municipio de ese comercio.
@Injectable()
export class AuthorizeBusinessMutationService {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async ensureMutable(
    businessId: string,
    managerId: string,
  ): Promise<Result<Business>> {
    const existing = await this.writer.findAdminById(businessId);
    if (!existing) {
      return Result.failure(new BusinessNotFoundError(businessId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new BusinessForbiddenError(managerId, existing.municipalityId.value),
      );
    }

    return Result.success(existing);
  }
}
