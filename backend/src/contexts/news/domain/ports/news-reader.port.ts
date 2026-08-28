import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { NewsItem } from '../entities/news-item.entity';
import { NewsCategory } from '../value-objects/news-category.vo';

export interface FindPublishedNewsParams {
  municipalityId: MunicipalityId;
  // Filtro opcional por categoría. Va en la consulta y no en el cliente: con
  // paginación por cursor, filtrar la página ya cargada mentiría — una
  // categoría que solo aparece en la página 3 daría "no hay resultados".
  category?: NewsCategory;
  cursor?: string;
  limit: number;
}

export interface NewsListResult {
  // Fijadas: sin paginar, pocas por diseño de producto.
  pinned: NewsItem[];
  // No fijadas: paginadas por cursor.
  items: NewsItem[];
  nextCursor: string | null;
}

export interface FindManagedNewsParams {
  municipalityId: MunicipalityId;
  // El gestor sí ve las archivadas: son las que puede querer recuperar o
  // corregir. El vecino no las ve en el listado público.
  includeArchived: boolean;
  cursor?: string;
  limit: number;
}

export interface NewsReaderPort {
  findPublished(params: FindPublishedNewsParams): Promise<NewsListResult>;

  // Histórico del vecino: solo archivadas. Endpoint aparte y no un flag del
  // listado publicado, para no ensuciar la semántica de "publicadas" ni
  // devolver fijadas archivadas, que es una contradicción.
  findArchived(params: FindPublishedNewsParams): Promise<NewsListResult>;

  findForManager(params: FindManagedNewsParams): Promise<NewsListResult>;

  // Detalle público: cualquier noticia existente del municipio, archivada o
  // no (se accede por enlace directo, ej. desde una notificación push
  // antigua). El municipio es OBLIGATORIO: ninguna consulta se escribe sin
  // filtrar por municipio.
  findByIdPublished(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<NewsItem | null>;

  // Categorías realmente presentes en el municipio. Sin esto, la barra de
  // filtros solo podría ofrecer las de la página cargada.
  findCategories(municipalityId: MunicipalityId): Promise<NewsCategory[]>;
}

export const NEWS_READER_PORT = Symbol('NEWS_READER_PORT');
