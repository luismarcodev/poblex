import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { Business } from '../../domain/entities/business.entity';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

export interface ReorderBusinessPhotosInput {
  businessId: string;
  managerId: string;
  orderedPhotoIds: string[];
}

@Injectable()
export class ReorderBusinessPhotosUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    private readonly authorize: AuthorizeBusinessMutationService,
  ) {}

  async execute(input: ReorderBusinessPhotosInput): Promise<Result<Business>> {
    const authResult = await this.authorize.ensureMutable(
      input.businessId,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    // El array recibido debe ser exactamente el mismo conjunto de fotos que
    // ya tiene el comercio — ni de más ni de menos — o el reordenado
    // silenciosamente perdería o inventaría fotos.
    const existingIds = authResult.value.photos
      .map((photo) => photo.id)
      .toSorted();
    const incomingIds = [...input.orderedPhotoIds].sort();
    const sameSet =
      existingIds.length === incomingIds.length &&
      existingIds.every((id, index) => id === incomingIds[index]);
    if (!sameSet) {
      return Result.failure(
        new ValidationError(
          'orderedPhotoIds must match the business current photos exactly',
        ),
      );
    }

    await this.writer.reorderPhotos(input.businessId, input.orderedPhotoIds);
    const updated = await this.writer.findAdminById(input.businessId);
    return Result.success(updated!);
  }
}
