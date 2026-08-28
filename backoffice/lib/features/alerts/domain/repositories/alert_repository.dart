import '../../../../core/result/result.dart';
import '../entities/managed_alert.dart';

abstract interface class AlertRepository {
  Future<Result<ManagedAlertsPage>> getManagedAlerts({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  });

  Future<Result<ManagedAlert>> getById({
    required String id,
    required String municipalityId,
  });

  Future<Result<ManagedAlert>> create(SaveManualAlertInput input);
  Future<Result<ManagedAlert>> update(SaveManualAlertInput input);
  Future<Result<void>> delete(String id);
}
