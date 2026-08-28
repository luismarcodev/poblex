import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { EventForbiddenError } from '../../domain/errors/event-errors';
import type { EventListResult } from '../../domain/ports/event-reader.port';
import {
  ListUpcomingEventsUseCase,
  type ListUpcomingEventsInput,
} from './list-upcoming-events.use-case';

export interface ListManagedEventsInput extends ListUpcomingEventsInput {
  managerId: string;
}

@Injectable()
export class ListManagedEventsUseCase {
  constructor(
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly listEvents: ListUpcomingEventsUseCase,
  ) {}

  async execute(
    input: ListManagedEventsInput,
  ): Promise<Result<EventListResult>> {
    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      input.municipalityId,
    );
    if (!isAuthorized) {
      return Result.failure(
        new EventForbiddenError(input.managerId, input.municipalityId),
      );
    }

    return this.listEvents.execute(input);
  }
}
