import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsAttachment } from '../entities/news-attachment.entity';
import { NewsItem } from '../entities/news-item.entity';
import { NewsCategory } from '../value-objects/news-category.vo';

export interface CreateNewsParams {
  municipalityId: MunicipalityId;
  title: LocalizedText;
  body: LocalizedText;
  category: NewsCategory;
  imageUrl?: string;
  pinned: boolean;
  publishedAt: Date;
}

export interface UpdateNewsFields {
  title?: LocalizedText;
  body?: LocalizedText;
  category?: NewsCategory;
  // PATCH semantics: undefined means no change, null clears the column.
  imageUrl?: string | null;
}

export interface CreateAttachmentParams {
  name: string;
  url: string;
  mimeType: string;
}

export interface NewsWriterPort {
  create(params: CreateNewsParams): Promise<NewsItem>;
  // Para comprobar municipio/existencia antes de mutar (admin, sin filtro
  // de archived — el gestor puede editar noticias ya archivadas).
  findAdminById(id: string): Promise<NewsItem | null>;
  update(id: string, fields: UpdateNewsFields): Promise<NewsItem>;
  setPinned(id: string, pinned: boolean): Promise<NewsItem>;
  setArchived(id: string, archived: boolean): Promise<NewsItem>;
  delete(id: string): Promise<void>;
  addAttachment(
    newsId: string,
    attachment: CreateAttachmentParams,
  ): Promise<NewsAttachment>;
  // Devuelve cuántas noticias se archivaron.
  archiveOlderThan(days: number): Promise<number>;
}

export const NEWS_WRITER_PORT = Symbol('NEWS_WRITER_PORT');
