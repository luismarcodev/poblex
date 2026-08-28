import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { FILE_STORAGE_PORT } from '../../../../shared/infrastructure/storage/file-storage.port';
import type {
  FileStoragePort,
  PresignedUploadUrl,
} from '../../../../shared/infrastructure/storage/file-storage.port';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

export interface RequestBusinessPhotoUploadUrlInput {
  businessId: string;
  managerId: string;
  fileName: string;
  contentType: string;
}

@Injectable()
export class RequestBusinessPhotoUploadUrlUseCase {
  constructor(
    private readonly authorize: AuthorizeBusinessMutationService,
    @Inject(FILE_STORAGE_PORT) private readonly storage: FileStoragePort,
  ) {}

  async execute(
    input: RequestBusinessPhotoUploadUrlInput,
  ): Promise<Result<PresignedUploadUrl>> {
    const authResult = await this.authorize.ensureMutable(
      input.businessId,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    const key = `business/${input.businessId}/${Date.now()}-${input.fileName}`;
    const presigned = await this.storage.createPresignedUploadUrl({
      key,
      contentType: input.contentType,
    });
    return Result.success(presigned);
  }
}
