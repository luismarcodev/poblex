import '../../../../core/result/result.dart';
import '../entities/managed_incident.dart';

abstract interface class IncidentRepository {
  Future<Result<ManagedIncidentsPage>> getManagedIncidents({
    required String municipalityId,
    IncidentStatus? status,
    String? category,
    String? cursor,
  });

  Future<Result<ManagedIncident>> changeStatus(ChangeIncidentStatusInput input);
}
