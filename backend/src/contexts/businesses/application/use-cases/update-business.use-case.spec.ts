import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../../domain/entities/business.entity';
import type {
  BusinessWriterPort,
  UpdateBusinessFields,
} from '../../domain/ports/business-writer.port';
import { BusinessCategory } from '../../domain/value-objects/business-category.vo';
import type { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';
import { UpdateBusinessUseCase } from './update-business.use-case';

const BUSINESS_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const MANAGER_ID = 'manager-1';
const PHONE = '961 000 010';

function businessWithPhone(phone: string | null): Business {
  return Business.create({
    id: BUSINESS_ID,
    municipalityId: MunicipalityId.create(
      '11111111-1111-4111-8111-111111111111',
    ),
    name: 'Bar Casa Pepe',
    category: BusinessCategory.create('bar'),
    description: null,
    address: null,
    phone,
    email: null,
    website: null,
    schedule: null,
    active: true,
    createdAt: new Date('2026-08-10T10:00:00.000Z'),
    photos: [],
  });
}

function buildHarness() {
  const existing = businessWithPhone(PHONE);
  const update = jest
    .fn<Promise<Business>, [string, UpdateBusinessFields]>()
    .mockImplementation((_id, fields) =>
      Promise.resolve(
        businessWithPhone(
          fields.phone === undefined ? existing.phone : fields.phone,
        ),
      ),
    );
  const writer = { update } as unknown as BusinessWriterPort;
  const authorize = {
    ensureMutable: jest.fn().mockResolvedValue(Result.success(existing)),
  } as unknown as AuthorizeBusinessMutationService;

  return { useCase: new UpdateBusinessUseCase(writer, authorize), update };
}

describe('UpdateBusinessUseCase optional field patch', () => {
  it('passes null to persistence to clear an existing phone', async () => {
    const { useCase, update } = buildHarness();

    const result = await useCase.execute({
      id: BUSINESS_ID,
      managerId: MANAGER_ID,
      phone: null,
    });

    expect(result.isSuccess).toBe(true);
    expect(result.isSuccess && result.value.phone).toBeNull();
    expect(update).toHaveBeenCalledWith(
      BUSINESS_ID,
      expect.objectContaining({ phone: null }),
    );
  });

  it('passes undefined when the phone field is omitted, keeping the current value', async () => {
    const { useCase, update } = buildHarness();

    const result = await useCase.execute({
      id: BUSINESS_ID,
      managerId: MANAGER_ID,
      name: 'Bar Casa Pepe (renovado)',
    });

    expect(result.isSuccess).toBe(true);
    expect(result.isSuccess && result.value.phone).toBe(PHONE);
    expect(update).toHaveBeenCalledWith(
      BUSINESS_ID,
      expect.objectContaining({ phone: undefined }),
    );
  });

  it('rejects clearing the name to an empty string', async () => {
    const { useCase, update } = buildHarness();

    const result = await useCase.execute({
      id: BUSINESS_ID,
      managerId: MANAGER_ID,
      name: '   ',
    });

    expect(result.isFailure).toBe(true);
    expect(update).not.toHaveBeenCalled();
  });
});
