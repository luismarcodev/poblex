import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type { NewsWriterPort } from '../../domain/ports/news-writer.port';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';

export interface ToggleNewsPinInput {
  id: string;
  managerId: string;
  pinned: boolean;
}

@Injectable()
export class ToggleNewsPinUseCase {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    private readonly authorize: AuthorizeNewsMutationService,
  ) {}

  async execute(input: ToggleNewsPinInput): Promise<Result<NewsItem>> {
    const authResult = await this.authorize.ensureMutable(
      input.id,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    const updated = await this.writer.setPinned(input.id, input.pinned);
    return Result.success(updated);
  }
}
