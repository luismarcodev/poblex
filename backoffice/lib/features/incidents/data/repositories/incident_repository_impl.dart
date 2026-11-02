import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_incident.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_datasource.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  const IncidentRepositoryImpl(this._remote);

  final IncidentRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedIncidentsPage>> getManagedIncidents({
    required String municipalityId,
    IncidentStatus? status,
    String? category,
    String? cursor,
  }) => _capture(
    () => _remote.getManagedIncidents(
      municipalityId: municipalityId,
      status: status,
      category: category,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<ManagedIncident>> changeStatus(
    ChangeIncidentStatusInput input,
  ) => _capture(() => _remote.changeStatus(input));

  @override
  Future<Result<List<IncidentStatusChange>>> getHistory(String incidentId) =>
      _capture(() => _remote.getHistory(incidentId));

  @override
  Future<Result<List<String>>> getCategories(String municipalityId) =>
      _capture(() => _remote.getCategories(municipalityId));
}
