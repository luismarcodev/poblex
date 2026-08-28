import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { FILE_STORAGE_PORT } from '../../../../shared/infrastructure/storage/file-storage.port';
import type { FileStoragePort } from '../../../../shared/infrastructure/storage/file-storage.port';
import { Business } from '../../domain/entities/business.entity';
import { BusinessForbiddenError } from '../../domain/errors/business-errors';
import { BUSINESS_READER_PORT } from '../../domain/ports/business-reader.port';
import type {
  BusinessListResult,
  BusinessReaderPort,
} from '../../domain/ports/business-reader.port';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

export interface ListManagedBusinessesInput {
  managerId: string;
  municipalityId: string;
  includeInactive?: boolean;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

// Listado de trabajo del backoffice: incluye desactivados, que el listado
// público del vecino nunca muestra.
@Injectable()
export class ListManagedBusinessesUseCase {
  constructor(
    @Inject(BUSINESS_READER_PORT) private readonly reader: BusinessReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(
    input: ListManagedBusinessesInput,
  ): Promise<Result<BusinessListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new BusinessForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const result = await this.reader.findForManager({
      municipalityId,
      includeInactive: input.includeInactive ?? false,
      cursor: input.cursor,
      limit:
        input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
          ? input.limit
          : DEFAULT_LIMIT,
    });
    return Result.success(result);
  }
}

// Despublicar/republicar sin borrar: un comercio cerrado temporalmente
// sigue siendo información útil, y el gestor puede reactivarlo si reabre.
@Injectable()
export class SetBusinessActiveUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    private readonly authorize: AuthorizeBusinessMutationService,
  ) {}

  async execute(
    id: string,
    managerId: string,
    active: boolean,
  ): Promise<Result<Business>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    const updated = await this.writer.setActive(id, active);
    return Result.success(updated);
  }
}

// Borrado físico, solo para altas erróneas. Purga las fotos de R2 antes de
// borrar la fila: news no lo necesita porque no borra adjuntos, comercios sí
// para no acumular basura en el bucket.
@Injectable()
export class DeleteBusinessUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    @Inject(FILE_STORAGE_PORT) private readonly storage: FileStoragePort,
    private readonly authorize: AuthorizeBusinessMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<void>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    for (const photo of authorized.value.photos) {
      await this.storage.deleteByPublicUrl(photo.url);
    }
    await this.writer.delete(id);
    return Result.success(undefined);
  }
}
