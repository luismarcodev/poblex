import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { NewsItem } from '../../domain/entities/news-item.entity';
import { NewsForbiddenError } from '../../domain/errors/news-errors';
import { NEWS_READER_PORT } from '../../domain/ports/news-reader.port';
import type {
  NewsListResult,
  NewsReaderPort,
} from '../../domain/ports/news-reader.port';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type { NewsWriterPort } from '../../domain/ports/news-writer.port';
import { AuthorizeNewsMutationService } from '../services/authorize-news-mutation.service';

export interface ListManagedNewsInput {
  managerId: string;
  municipalityId: string;
  includeArchived?: boolean;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

// Listado de trabajo del backoffice: incluye archivadas, que el listado
// público del vecino nunca muestra.
@Injectable()
export class ListManagedNewsUseCase {
  constructor(
    @Inject(NEWS_READER_PORT) private readonly reader: NewsReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: ListManagedNewsInput): Promise<Result<NewsListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new NewsForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const result = await this.reader.findForManager({
      municipalityId,
      includeArchived: input.includeArchived ?? false,
      cursor: input.cursor,
      limit:
        input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
          ? input.limit
          : DEFAULT_LIMIT,
    });
    return Result.success(result);
  }
}

// Archivar/desarchivar a mano. El auto-archivado a los 90 días sigue corriendo
// aparte; esto permite recuperar una noticia que el gestor quiere revivir.
@Injectable()
export class SetNewsArchivedUseCase {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    private readonly authorize: AuthorizeNewsMutationService,
  ) {}

  async execute(
    id: string,
    managerId: string,
    archived: boolean,
  ): Promise<Result<NewsItem>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    const updated = await this.writer.setArchived(id, archived);
    return Result.success(updated);
  }
}

@Injectable()
export class DeleteNewsUseCase {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
    private readonly authorize: AuthorizeNewsMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<void>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    await this.writer.delete(id);
    return Result.success(undefined);
  }
}
