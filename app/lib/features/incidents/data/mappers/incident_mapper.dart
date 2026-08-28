import '../../domain/entities/incident.dart';
import '../models/incident_model.dart';

abstract final class IncidentMapper {
  static Incident toDomain(IncidentModel model) => Incident(
    id: model.id,
    municipalityId: model.municipalityId,
    category: model.category,
    description: model.description,
    photoUrl: model.photoUrl,
    lat: model.lat,
    lng: model.lng,
    status: IncidentStatus.fromSlug(model.status),
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  static IncidentStatusChange statusChangeToDomain(
    IncidentStatusChangeModel model,
  ) => IncidentStatusChange(
    status: IncidentStatus.fromSlug(model.status),
    note: model.note,
    changedAt: model.changedAt,
  );

  static IncidentDetail detailToDomain(IncidentDetailModel model) =>
      IncidentDetail(
        incident: toDomain(model.incident),
        history: model.history
            .map(statusChangeToDomain)
            .toList(growable: false),
      );
}
