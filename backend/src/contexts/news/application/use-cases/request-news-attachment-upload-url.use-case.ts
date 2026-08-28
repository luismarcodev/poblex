import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { FILE_STORAGE_PORT } from '../../../../shared/infrastructure/storage/file-storage.port';
import type {
  FileStoragePort,
  PresignedUploadUrl,
} from '../../../../shared/infrastructure/storage/file-storage.port';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';

export interface RequestNewsAttachmentUploadUrlInput {
  newsId: string;
  managerId: string;
  fileName: string;
  contentType: string;
}

@Injectable()
export class RequestNewsAttachmentUploadUrlUseCase {
  constructor(
    private readonly authorize: AuthorizeNewsMutationService,
    @Inject(FILE_STORAGE_PORT) private readonly storage: FileStoragePort,
  ) {}

  async execute(
    input: RequestNewsAttachmentUploadUrlInput,
  ): Promise<Result<PresignedUploadUrl>> {
    const authResult = await this.authorize.ensureMutable(
      input.newsId,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    const key = `news/${input.newsId}/${Date.now()}-${input.fileName}`;
    const presigned = await this.storage.createPresignedUploadUrl({
      key,
      contentType: input.contentType,
    });
    return Result.success(presigned);
  }
}
