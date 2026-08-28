import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Business } from '../../domain/entities/business.entity';
import { BusinessForbiddenError } from '../../domain/errors/business-errors';
import type {
  BusinessWriterPort,
  CreateBusinessParams,
} from '../../domain/ports/business-writer.port';
import { CreateBusinessUseCase } from './create-business.use-case';

const SOLLANA = '11111111-1111-4111-8111-111111111111';
const FOREIGN = '33333333-3333-4333-8333-333333333333';
const MANAGER_ID = '9a8b7c6d-5e4f-4a3b-9c8d-7e6f5a4b3c2d';

function buildHarness(managedMunicipalities: string[]) {
  let sequence = 0;
  const create = jest
    .fn<Promise<Business>, [CreateBusinessParams]>()
    .mockImplementation((params) => {
      sequence += 1;
      return Promise.resolve(
        Business.create({
          id: `business-${sequence}`,
          municipalityId: params.municipalityId,
          name: params.name,
          category: params.category,
          description: params.description ?? null,
          address: params.address ?? null,
          phone: params.phone ?? null,
          email: params.email ?? null,
          website: params.website ?? null,
          schedule: params.schedule ?? null,
          active: true,
          createdAt: new Date(),
          photos: [],
        }),
      );
    });
  const writer = { create } as unknown as BusinessWriterPort;

  const managers = {
    isManagerOfMunicipality: jest
      .fn()
      .mockImplementation((_managerId: string, municipalityId: string) =>
        Promise.resolve(managedMunicipalities.includes(municipalityId)),
      ),
  } as unknown as ManagerRepositoryPort;

  return { useCase: new CreateBusinessUseCase(writer, managers), create };
}

const validInput = {
  managerId: MANAGER_ID,
  municipalityId: SOLLANA,
  name: 'Bar Casa Pepe',
  category: 'bar',
};

describe('CreateBusinessUseCase', () => {
  it('creates a business with only the required fields', async () => {
    const { useCase, create } = buildHarness([SOLLANA]);

    const result = await useCase.execute(validInput);

    expect(result.isSuccess).toBe(true);
    expect(create).toHaveBeenCalledTimes(1);
  });

  it('rejects a manager who is not authorized for the municipality', async () => {
    const { useCase, create } = buildHarness([]);

    const result = await useCase.execute({
      ...validInput,
      municipalityId: FOREIGN,
    });

    expect(result.isFailure && result.error).toBeInstanceOf(
      BusinessForbiddenError,
    );
    expect(create).not.toHaveBeenCalled();
  });

  it('rejects an empty name before touching the authorization check', async () => {
    const { useCase, create } = buildHarness([SOLLANA]);

    const result = await useCase.execute({ ...validInput, name: '   ' });

    expect(result.isFailure).toBe(true);
    expect(create).not.toHaveBeenCalled();
  });

  it('accepts an optional description and optional contact fields', async () => {
    const { useCase, create } = buildHarness([SOLLANA]);

    const result = await useCase.execute({
      ...validInput,
      description: { es: 'Bar de toda la vida' },
      phone: '961 000 010',
    });

    expect(result.isSuccess).toBe(true);
    expect(create.mock.calls[0][0].phone).toBe('961 000 010');
  });
});
