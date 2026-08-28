import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/event.dart';
import '../models/event_model.dart';

abstract final class EventMapper {
  static MunicipalEvent toDomain(EventModel model) => MunicipalEvent(
    id: model.id,
    municipalityId: model.municipalityId,
    title: LocalizedText(es: model.title.es, va: model.title.va),
    description: LocalizedText(
      es: model.description.es,
      va: model.description.va,
    ),
    startAt: model.startAt,
    endAt: model.endAt,
    locationName: model.locationName,
    lat: model.lat,
    lng: model.lng,
    category: model.category,
  );
}
