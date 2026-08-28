import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../entities/business.entity';
import { BusinessCategory } from '../value-objects/business-category.vo';

export interface FindPublishedBusinessesParams {
  municipalityId: MunicipalityId;
  // Filtro opcional por categoría, en la consulta y no en el cliente — con
  // paginación por cursor, filtrar la página ya cargada mentiría.
  category?: BusinessCategory;
  cursor?: string;
  limit: number;
}

export interface BusinessListResult {
  items: Business[];
  nextCursor: string | null;
}

export interface FindManagedBusinessesParams {
  municipalityId: MunicipalityId;
  // El gestor sí ve los desactivados: son los que puede querer reactivar.
  includeInactive: boolean;
  cursor?: string;
  limit: number;
}

export interface BusinessReaderPort {
  findPublished(
    params: FindPublishedBusinessesParams,
  ): Promise<BusinessListResult>;

  findForManager(
    params: FindManagedBusinessesParams,
  ): Promise<BusinessListResult>;

  // Detalle público: solo comercios activos. El municipio es obligatorio —
  // ninguna consulta se escribe sin filtrar por municipio.
  findByIdPublished(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Business | null>;

  // Categorías realmente presentes (activas) en el municipio. Sin esto, la
  // barra de filtros solo podría ofrecer las de la página cargada.
  findCategories(municipalityId: MunicipalityId): Promise<BusinessCategory[]>;
}

export const BUSINESS_READER_PORT = Symbol('BUSINESS_READER_PORT');
