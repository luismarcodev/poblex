import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../entities/managed_incident.dart';
import '../repositories/incident_repository.dart';

const int maxIncidentNoteLength = 1000;

class GetManagedIncidents {
  const GetManagedIncidents(this._repository);

  final IncidentRepository _repository;

  Future<Result<ManagedIncidentsPage>> call({
    required String municipalityId,
    IncidentStatus? status,
    String? category,
    String? cursor,
  }) => _repository.getManagedIncidents(
    municipalityId: municipalityId,
    status: status,
    category: _normalizedCategory(category),
    cursor: cursor,
  );
}

class ChangeManagedIncidentStatus {
  const ChangeManagedIncidentStatus(this._repository);

  final IncidentRepository _repository;

  Future<Result<ManagedIncident>> call(ChangeIncidentStatusInput input) {
    if (!input.incident.status.canTransitionTo(input.status)) {
      return Future.value(
        const Failure(
          ValidationFailure(message: 'incident_invalid_transition'),
        ),
      );
    }
    final note = input.note?.trim();
    if (note != null && note.length > maxIncidentNoteLength) {
      return Future.value(
        const Failure(ValidationFailure(message: 'incident_note_too_long')),
      );
    }
    return _repository.changeStatus(
      ChangeIncidentStatusInput(
        incident: input.incident,
        status: input.status,
        note: note == null || note.isEmpty ? null : note,
      ),
    );
  }
}

class GetIncidentHistory {
  const GetIncidentHistory(this._repository);

  final IncidentRepository _repository;

  Future<Result<List<IncidentStatusChange>>> call(String incidentId) =>
      _repository.getHistory(incidentId);
}

class ListIncidentCategories {
  const ListIncidentCategories(this._repository);

  final IncidentRepository _repository;

  Future<Result<List<String>>> call(String municipalityId) =>
      _repository.getCategories(municipalityId);
}

String? _normalizedCategory(String? category) {
  final value = category?.trim().toLowerCase();
  return value == null || value.isEmpty ? null : value;
}
