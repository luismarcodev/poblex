import { Injectable } from '@nestjs/common';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { NewsAttachment } from '../../../domain/entities/news-attachment.entity';
import { NewsItem } from '../../../domain/entities/news-item.entity';
import { NewsCategory } from '../../../domain/value-objects/news-category.vo';
import type {
  FindManagedNewsParams,
  FindPublishedNewsParams,
  NewsListResult,
  NewsReaderPort,
} from '../../../domain/ports/news-reader.port';
import type {
  CreateAttachmentParams,
  CreateNewsParams,
  NewsWriterPort,
  UpdateNewsFields,
} from '../../../domain/ports/news-writer.port';
import { NewsMapper, PrismaNewsWithAttachments } from './news.mapper';

function encodeCursor(publishedAt: Date, id: string): string {
  return Buffer.from(`${publishedAt.toISOString()}|${id}`).toString(
    'base64url',
  );
}

function decodeCursor(cursor: string): { publishedAt: Date; id: string } {
  const [iso, id] = Buffer.from(cursor, 'base64url')
    .toString('utf-8')
    .split('|');
  return { publishedAt: new Date(iso), id };
}

// Orden descendente por fecha con el id como desempate estable: dos noticias
// publicadas en el mismo instante no se pierden ni se repiten entre páginas.
function buildCursorFilter(cursor?: string) {
  if (!cursor) return {};
  const { publishedAt, id } = decodeCursor(cursor);
  return {
    OR: [{ publishedAt: { lt: publishedAt } }, { publishedAt, id: { lt: id } }],
  };
}

// Se pide una fila de más que el límite: si llega, hay página siguiente.
function paginate(
  rows: PrismaNewsWithAttachments[],
  limit: number,
): { rows: PrismaNewsWithAttachments[]; nextCursor: string | null } {
  const hasMore = rows.length > limit;
  const pageRows = hasMore ? rows.slice(0, limit) : rows;
  const lastRow = pageRows[pageRows.length - 1];

  return {
    rows: pageRows,
    nextCursor:
      hasMore && lastRow ? encodeCursor(lastRow.publishedAt, lastRow.id) : null,
  };
}

@Injectable()
export class NewsPrismaRepository implements NewsReaderPort, NewsWriterPort {
  constructor(private readonly prisma: PrismaService) {}

  async findPublished(
    params: FindPublishedNewsParams,
  ): Promise<NewsListResult> {
    // Las fijadas se devuelven completas en cada página: son pocas por diseño
    // de producto y el cliente las pinta aparte de la lista paginada.
    const pinnedRows: PrismaNewsWithAttachments[] =
      await this.prisma.news.findMany({
        where: {
          municipalityId: params.municipalityId.value,
          archived: false,
          pinned: true,
          category: params.category?.value,
        },
        include: { attachments: true },
        orderBy: { publishedAt: 'desc' },
      });

    const itemRows: PrismaNewsWithAttachments[] =
      await this.prisma.news.findMany({
        where: {
          municipalityId: params.municipalityId.value,
          archived: false,
          pinned: false,
          category: params.category?.value,
          ...buildCursorFilter(params.cursor),
        },
        include: { attachments: true },
        orderBy: [{ publishedAt: 'desc' }, { id: 'desc' }],
        take: params.limit + 1,
      });

    const page = paginate(itemRows, params.limit);

    return {
      pinned: pinnedRows.map((row) => NewsMapper.toDomain(row)),
      items: page.rows.map((row) => NewsMapper.toDomain(row)),
      nextCursor: page.nextCursor,
    };
  }

  async findArchived(params: FindPublishedNewsParams): Promise<NewsListResult> {
    const rows: PrismaNewsWithAttachments[] = await this.prisma.news.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        archived: true,
        category: params.category?.value,
        ...buildCursorFilter(params.cursor),
      },
      include: { attachments: true },
      orderBy: [{ publishedAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });

    const page = paginate(rows, params.limit);

    return {
      // Una noticia archivada ya no destaca: el histórico nunca trae fijadas.
      pinned: [],
      items: page.rows.map((row) => NewsMapper.toDomain(row)),
      nextCursor: page.nextCursor,
    };
  }

  async findCategories(
    municipalityId: MunicipalityId,
  ): Promise<NewsCategory[]> {
    const rows = await this.prisma.news.findMany({
      where: { municipalityId: municipalityId.value, archived: false },
      select: { category: true },
      distinct: ['category'],
      orderBy: { category: 'asc' },
    });
    return rows.map((row) => NewsCategory.create(row.category));
  }

  async findForManager(params: FindManagedNewsParams): Promise<NewsListResult> {
    const rows: PrismaNewsWithAttachments[] = await this.prisma.news.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        archived: params.includeArchived ? undefined : false,
        ...buildCursorFilter(params.cursor),
      },
      include: { attachments: true },
      orderBy: [{ publishedAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });

    const page = paginate(rows, params.limit);

    return {
      // La vista de gestión no separa fijadas: es una lista de trabajo, no la
      // portada del vecino.
      pinned: [],
      items: page.rows.map((row) => NewsMapper.toDomain(row)),
      nextCursor: page.nextCursor,
    };
  }

  async findByIdPublished(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<NewsItem | null> {
    // findFirst y no findUnique: el municipio forma parte del filtro, y una
    // noticia de otro pueblo tiene que salir como inexistente.
    const row = await this.prisma.news.findFirst({
      where: { id, municipalityId: municipalityId.value, archived: false },
      include: { attachments: true },
    });
    return row ? NewsMapper.toDomain(row) : null;
  }

  // Lectura de gestión: sin filtro de municipio porque quien llama ya ha
  // comprobado la autorización con AuthorizeNewsMutationService, que necesita
  // leer la noticia justamente para saber a qué municipio pertenece.
  async findAdminById(id: string): Promise<NewsItem | null> {
    const row = await this.prisma.news.findUnique({
      where: { id },
      include: { attachments: true },
    });
    return row ? NewsMapper.toDomain(row) : null;
  }

  async create(params: CreateNewsParams): Promise<NewsItem> {
    const row = await this.prisma.news.create({
      data: {
        municipalityId: params.municipalityId.value,
        title: params.title.toJSON() as Prisma.InputJsonValue,
        body: params.body.toJSON() as Prisma.InputJsonValue,
        category: params.category.value,
        imageUrl: params.imageUrl,
        pinned: params.pinned,
        publishedAt: params.publishedAt,
      },
      include: { attachments: true },
    });
    return NewsMapper.toDomain(row);
  }

  async update(id: string, fields: UpdateNewsFields): Promise<NewsItem> {
    const row = await this.prisma.news.update({
      where: { id },
      data: {
        title: fields.title?.toJSON() as Prisma.InputJsonValue | undefined,
        body: fields.body?.toJSON() as Prisma.InputJsonValue | undefined,
        category: fields.category?.value,
        imageUrl: fields.imageUrl,
      },
      include: { attachments: true },
    });
    return NewsMapper.toDomain(row);
  }

  async setPinned(id: string, pinned: boolean): Promise<NewsItem> {
    const row = await this.prisma.news.update({
      where: { id },
      data: { pinned },
      include: { attachments: true },
    });
    return NewsMapper.toDomain(row);
  }

  async setArchived(id: string, archived: boolean): Promise<NewsItem> {
    const row = await this.prisma.news.update({
      where: { id },
      data: { archived },
      include: { attachments: true },
    });
    return NewsMapper.toDomain(row);
  }

  async delete(id: string): Promise<void> {
    // Los adjuntos caen por ON DELETE CASCADE.
    await this.prisma.news.delete({ where: { id } });
  }

  async addAttachment(
    newsId: string,
    attachment: CreateAttachmentParams,
  ): Promise<NewsAttachment> {
    const row = await this.prisma.newsAttachment.create({
      data: {
        newsId,
        name: attachment.name,
        url: attachment.url,
        mimeType: attachment.mimeType,
      },
    });
    return NewsAttachment.create(row);
  }

  async archiveOlderThan(days: number): Promise<number> {
    const threshold = new Date(Date.now() - days * 86_400_000);
    const result = await this.prisma.news.updateMany({
      where: { archived: false, publishedAt: { lt: threshold } },
      data: { archived: true },
    });
    return result.count;
  }
}
