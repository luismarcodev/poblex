import { MunicipalEvent } from '../../domain/entities/event.entity';
import { EventResponseDto } from '../http/dto/event-response.dto';

// El servidor devuelve el objeto bilingüe COMPLETO (es + va), sin resolver a
// un solo idioma — el cliente decide y permite el conmutador manual.
export class EventHttpMapper {
  static toResponseDto(event: MunicipalEvent): EventResponseDto {
    return {
      id: event.id,
      municipalityId: event.municipalityId.value,
      title: event.title.toJSON(),
      description: event.description.toJSON(),
      startAt: event.startAt.toISOString(),
      endAt: event.endAt?.toISOString() ?? null,
      locationName: event.locationName,
      lat: event.lat,
      lng: event.lng,
      category: event.category.value,
    };
  }
}
