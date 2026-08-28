import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';

class AlertRepositoryImpl implements AlertRepository {
  const AlertRepositoryImpl(this._remote);

  final AlertRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedAlertsPage>> getManagedAlerts({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) => _capture(
    () => _remote.getManagedAlerts(
      municipalityId: municipalityId,
      includeExpired: includeExpired,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<ManagedAlert>> getById({
    required String id,
    required String municipalityId,
  }) => _capture(() => _remote.getById(id: id, municipalityId: municipalityId));

  @override
  Future<Result<ManagedAlert>> create(SaveManualAlertInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<ManagedAlert>> update(SaveManualAlertInput input) =>
      _capture(() => _remote.update(input));

  @override
  Future<Result<void>> delete(String id) => _capture(() => _remote.delete(id));
}
