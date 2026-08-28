import { Business } from '../../domain/entities/business.entity';
import { BusinessResponseDto } from '../http/dto/business-response.dto';

// El servidor devuelve el objeto bilingüe COMPLETO (es + va) de la
// descripción, sin resolver a un solo idioma — el cliente decide.
export class BusinessHttpMapper {
  static toResponseDto(business: Business): BusinessResponseDto {
    return {
      id: business.id,
      municipalityId: business.municipalityId.value,
      name: business.name,
      category: business.category.value,
      description: business.description?.toJSON() ?? null,
      address: business.address,
      phone: business.phone,
      email: business.email,
      website: business.website,
      schedule: business.schedule,
      active: business.active,
      photos: business.photos
        .slice()
        .sort((a, b) => a.position - b.position)
        .map((photo) => ({
          id: photo.id,
          url: photo.url,
          mimeType: photo.mimeType,
          position: photo.position,
        })),
    };
  }
}
