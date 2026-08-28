import { Inject, Injectable } from '@nestjs/common';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Result } from '../../../../shared/domain/result';
import {
  NewsForbiddenError,
  NewsNotFoundError,
} from '../../domain/errors/news-errors';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type { NewsWriterPort } from '../../domain/ports/news-writer.port';

// Compartido por todos los casos de uso que MUTAN una noticia existente
// (update, pin, adjuntos): comprueba que existe y que el gestor pertenece
// al municipio de esa noticia — regla repetida en 4 sitios, no duplicada.
@Injectable()
export class AuthorizeNewsMutationService {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async ensureMutable(
    newsId: string,
    managerId: string,
  ): Promise<Result<NewsItem>> {
    const existing = await this.writer.findAdminById(newsId);
    if (!existing) {
      return Result.failure(new NewsNotFoundError(newsId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new NewsForbiddenError(managerId, existing.municipalityId.value),
      );
    }

    return Result.success(existing);
  }
}
