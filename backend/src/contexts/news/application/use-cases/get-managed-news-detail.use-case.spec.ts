import { Result } from '../../../../shared/domain/result';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';
import { NewsNotFoundError } from '../../domain/errors/news-errors';
import { GetManagedNewsDetailUseCase } from './get-managed-news-detail.use-case';

describe('GetManagedNewsDetailUseCase', () => {
  it('uses the same municipality authorization as mutations', async () => {
    const error = new NewsNotFoundError('missing');
    const ensureMutable = jest.fn().mockResolvedValue(Result.failure(error));
    const authorization = {
      ensureMutable,
    } as unknown as AuthorizeNewsMutationService;
    const useCase = new GetManagedNewsDetailUseCase(authorization);

    const result = await useCase.execute('missing', 'manager-1');

    expect(ensureMutable).toHaveBeenCalledWith('missing', 'manager-1');
    expect(result.isFailure && result.error).toBe(error);
  });
});
