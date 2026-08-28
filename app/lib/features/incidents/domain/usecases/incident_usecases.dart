import '../../../../core/result/result.dart';
import '../entities/incident.dart';
import '../repositories/incident_repository.dart';

class ReportIncident {
  const ReportIncident(this._repository);
  final IncidentRepository _repository;

  Future<Result<Incident>> call({
    required String municipalityId,
    required String category,
    required String description,
    double? lat,
    double? lng,
  }) => _repository.report(
    municipalityId: municipalityId,
    category: category,
    description: description,
    lat: lat,
    lng: lng,
  );
}

class UploadIncidentPhoto {
  const UploadIncidentPhoto(this._repository);
  final IncidentRepository _repository;

  Future<Result<Incident>> call({
    required String incidentId,
    required List<int> bytes,
    required String filename,
  }) => _repository.uploadPhoto(
    incidentId: incidentId,
    bytes: bytes,
    filename: filename,
  );
}

class GetMyIncidents {
  const GetMyIncidents(this._repository);
  final IncidentRepository _repository;

  Future<Result<IncidentPage>> call({String? cursor}) =>
      _repository.listMine(cursor: cursor);
}

class GetMyIncidentDetail {
  const GetMyIncidentDetail(this._repository);
  final IncidentRepository _repository;

  Future<Result<IncidentDetail>> call(String id) => _repository.detail(id);
}
