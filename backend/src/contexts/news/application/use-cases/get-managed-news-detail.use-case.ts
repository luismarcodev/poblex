import { Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';
import { NewsItem } from '../../domain/entities/news-item.entity';

@Injectable()
export class GetManagedNewsDetailUseCase {
  constructor(private readonly authorization: AuthorizeNewsMutationService) {}

  execute(newsId: string, managerId: string): Promise<Result<NewsItem>> {
    return this.authorization.ensureMutable(newsId, managerId);
  }
}
