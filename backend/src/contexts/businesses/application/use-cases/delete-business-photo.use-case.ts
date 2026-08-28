import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { FILE_STORAGE_PORT } from '../../../../shared/infrastructure/storage/file-storage.port';
import type { FileStoragePort } from '../../../../shared/infrastructure/storage/file-storage.port';
import { BusinessNotFoundError } from '../../domain/errors/business-errors';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

export interface DeleteBusinessPhotoInput {
  businessId: string;
  photoId: string;
  managerId: string;
}

// News no borra adjuntos — esto es nuevo. Purga el objeto de R2 antes de
// borrar la fila, para no acumular basura en el bucket.
@Injectable()
export class DeleteBusinessPhotoUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    @Inject(FILE_STORAGE_PORT) private readonly storage: FileStoragePort,
    private readonly authorize: AuthorizeBusinessMutationService,
  ) {}

  async execute(input: DeleteBusinessPhotoInput): Promise<Result<void>> {
    const authResult = await this.authorize.ensureMutable(
      input.businessId,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    // La propiedad de la foto se comprueba aquí, no solo su existencia: un
    // photoId válido de OTRO comercio no puede borrarse a través de este id.
    const photo = await this.writer.findPhotoById(
      input.businessId,
      input.photoId,
    );
    if (!photo) {
      return Result.failure(new BusinessNotFoundError(input.photoId));
    }

    await this.storage.deleteByPublicUrl(photo.url);
    await this.writer.deletePhoto(input.photoId);
    return Result.success(undefined);
  }
}
