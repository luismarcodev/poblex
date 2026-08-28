import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { MunicipalEvent } from '../../domain/entities/event.entity';
import {
  EventForbiddenError,
  EventNotFoundError,
} from '../../domain/errors/event-errors';
import { EVENT_READER_PORT } from '../../domain/ports/event-reader.port';
import type { EventReaderPort } from '../../domain/ports/event-reader.port';

// Compartido por update y delete: el evento existe y el gestor pertenece a su
// municipio. La comprobación va en el caso de uso, no solo en el controlador.
@Injectable()
export class AuthorizeEventMutationService {
  constructor(
    @Inject(EVENT_READER_PORT) private readonly reader: EventReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async ensureMutable(
    eventId: string,
    managerId: string,
  ): Promise<Result<MunicipalEvent>> {
    const existing = await this.reader.findById(eventId);
    if (!existing) {
      return Result.failure(new EventNotFoundError(eventId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new EventForbiddenError(managerId, existing.municipalityId.value),
      );
    }

    return Result.success(existing);
  }
}
