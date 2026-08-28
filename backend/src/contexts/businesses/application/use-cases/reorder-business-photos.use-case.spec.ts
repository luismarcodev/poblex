import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../../domain/entities/business.entity';
import { BusinessPhoto } from '../../domain/entities/business-photo.entity';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';
import { BusinessCategory } from '../../domain/value-objects/business-category.vo';
import type { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';
import { ReorderBusinessPhotosUseCase } from './reorder-business-photos.use-case';

const BUSINESS_ID = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const MANAGER_ID = 'manager-1';
const PHOTO_A = 'photo-a';
const PHOTO_B = 'photo-b';
const PHOTO_C = 'photo-c';

function businessWithPhotos(): Business {
  return Business.create({
    id: BUSINESS_ID,
    municipalityId: MunicipalityId.create(
      '11111111-1111-4111-8111-111111111111',
    ),
    name: 'Bar Casa Pepe',
    category: BusinessCategory.create('bar'),
    description: null,
    address: null,
    phone: null,
    email: null,
    website: null,
    schedule: null,
    active: true,
    createdAt: new Date('2026-08-10T10:00:00.000Z'),
    photos: [PHOTO_A, PHOTO_B, PHOTO_C].map((id, position) =>
      BusinessPhoto.create({
        id,
        url: `https://cdn.example/${id}.jpg`,
        mimeType: 'image/jpeg',
        position,
      }),
    ),
  });
}

function buildHarness() {
  const existing = businessWithPhotos();
  const reorderPhotos = jest.fn().mockResolvedValue(undefined);
  const findAdminById = jest.fn().mockResolvedValue(existing);
  const writer = {
    reorderPhotos,
    findAdminById,
  } as unknown as BusinessWriterPort;
  const authorize = {
    ensureMutable: jest.fn().mockResolvedValue(Result.success(existing)),
  } as unknown as AuthorizeBusinessMutationService;

  return {
    useCase: new ReorderBusinessPhotosUseCase(writer, authorize),
    reorderPhotos,
  };
}

describe('ReorderBusinessPhotosUseCase', () => {
  it('reorders when the incoming set matches the existing photos exactly', async () => {
    const { useCase, reorderPhotos } = buildHarness();

    const result = await useCase.execute({
      businessId: BUSINESS_ID,
      managerId: MANAGER_ID,
      orderedPhotoIds: [PHOTO_C, PHOTO_A, PHOTO_B],
    });

    expect(result.isSuccess).toBe(true);
    expect(reorderPhotos).toHaveBeenCalledWith(BUSINESS_ID, [
      PHOTO_C,
      PHOTO_A,
      PHOTO_B,
    ]);
  });

  it('rejects a set missing one of the current photos', async () => {
    const { useCase, reorderPhotos } = buildHarness();

    const result = await useCase.execute({
      businessId: BUSINESS_ID,
      managerId: MANAGER_ID,
      orderedPhotoIds: [PHOTO_A, PHOTO_B],
    });

    expect(result.isFailure).toBe(true);
    expect(reorderPhotos).not.toHaveBeenCalled();
  });

  it('rejects a set with a photo id that does not belong to this business', async () => {
    const { useCase, reorderPhotos } = buildHarness();

    const result = await useCase.execute({
      businessId: BUSINESS_ID,
      managerId: MANAGER_ID,
      orderedPhotoIds: [PHOTO_A, PHOTO_B, 'someone-elses-photo'],
    });

    expect(result.isFailure).toBe(true);
    expect(reorderPhotos).not.toHaveBeenCalled();
  });
});
