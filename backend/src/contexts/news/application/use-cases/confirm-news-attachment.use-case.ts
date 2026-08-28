import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { NewsAttachment } from '../../domain/entities/news-attachment.entity';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type { NewsWriterPort } from '../../domain/ports/news-writer.port';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';

export interface ConfirmNewsAttachmentInput {
  newsId: string;
  managerId: string;
  name: string;
  url: string;
  mimeType: string;
}

@Injectable()
export class ConfirmNewsAttachmentUseCase {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    private readonly authorize: AuthorizeNewsMutationService,
  ) {}

  async execute(
    input: ConfirmNewsAttachmentInput,
  ): Promise<Result<NewsAttachment>> {
    const authResult = await this.authorize.ensureMutable(
      input.newsId,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    const attachment = await this.writer.addAttachment(input.newsId, {
      name: input.name,
      url: input.url,
      mimeType: input.mimeType,
    });
    return Result.success(attachment);
  }
}
