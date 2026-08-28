import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../entities/business.entity';
import { BusinessPhoto } from '../entities/business-photo.entity';
import { BusinessCategory } from '../value-objects/business-category.vo';

export interface CreateBusinessParams {
  municipalityId: MunicipalityId;
  name: string;
  category: BusinessCategory;
  description?: LocalizedText;
  address?: string;
  phone?: string;
  email?: string;
  website?: string;
  schedule?: string;
}

export interface UpdateBusinessFields {
  // PATCH semantics: undefined means no change, null clears the column
  // (only applies to the optional fields — name/category are never null).
  name?: string;
  category?: BusinessCategory;
  description?: LocalizedText | null;
  address?: string | null;
  phone?: string | null;
  email?: string | null;
  website?: string | null;
  schedule?: string | null;
}

export interface CreateBusinessPhotoParams {
  url: string;
  mimeType: string;
}

export interface BusinessWriterPort {
  create(params: CreateBusinessParams): Promise<Business>;
  // Para comprobar municipio/existencia antes de mutar (admin, sin filtro de
  // active — el gestor puede editar un comercio ya desactivado).
  findAdminById(id: string): Promise<Business | null>;
  update(id: string, fields: UpdateBusinessFields): Promise<Business>;
  setActive(id: string, active: boolean): Promise<Business>;
  delete(id: string): Promise<void>;

  addPhoto(
    businessId: string,
    photo: CreateBusinessPhotoParams,
  ): Promise<BusinessPhoto>;
  // Null si no existe o no pertenece a businessId — la propiedad se
  // comprueba aquí, no solo la existencia del id.
  findPhotoById(
    businessId: string,
    photoId: string,
  ): Promise<BusinessPhoto | null>;
  deletePhoto(photoId: string): Promise<void>;
  reorderPhotos(businessId: string, orderedPhotoIds: string[]): Promise<void>;
}

export const BUSINESS_WRITER_PORT = Symbol('BUSINESS_WRITER_PORT');
