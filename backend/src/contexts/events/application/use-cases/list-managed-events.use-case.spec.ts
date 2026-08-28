import { Result } from '../../../../shared/domain/result';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { EventForbiddenError } from '../../domain/errors/event-errors';
import { ListManagedEventsUseCase } from './list-managed-events.use-case';
import type { ListUpcomingEventsUseCase } from './list-upcoming-events.use-case';

const MANAGER_ID = 'manager-1';
const MUNICIPALITY_ID = '11111111-1111-4111-8111-111111111111';

describe('ListManagedEventsUseCase', () => {
  it('rejects a manager outside the requested municipality', async () => {
    const managers = {
      isManagerOfMunicipality: jest.fn().mockResolvedValue(false),
    } as unknown as ManagerRepositoryPort;
    const execute = jest.fn();
    const listEvents = { execute } as unknown as ListUpcomingEventsUseCase;
    const useCase = new ListManagedEventsUseCase(managers, listEvents);

    const result = await useCase.execute({
      managerId: MANAGER_ID,
      municipalityId: MUNICIPALITY_ID,
    });

    expect(result.isFailure).toBe(true);
    if (result.isFailure) {
      expect(result.error).toBeInstanceOf(EventForbiddenError);
    }
    expect(execute).not.toHaveBeenCalled();
  });

  it('delegates the listing after municipality authorization', async () => {
    const managers = {
      isManagerOfMunicipality: jest.fn().mockResolvedValue(true),
    } as unknown as ManagerRepositoryPort;
    const listResult = { items: [], nextCursor: null };
    const execute = jest.fn().mockResolvedValue(Result.success(listResult));
    const listEvents = { execute } as unknown as ListUpcomingEventsUseCase;
    const useCase = new ListManagedEventsUseCase(managers, listEvents);

    const result = await useCase.execute({
      managerId: MANAGER_ID,
      municipalityId: MUNICIPALITY_ID,
      includePast: true,
    });

    expect(result.isSuccess).toBe(true);
    if (result.isSuccess) {
      expect(result.value).toBe(listResult);
    }
    expect(execute).toHaveBeenCalledWith({
      managerId: MANAGER_ID,
      municipalityId: MUNICIPALITY_ID,
      includePast: true,
    });
  });
});
