import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../entities/managed_alert.dart';
import '../repositories/alert_repository.dart';

class GetManagedAlerts {
  const GetManagedAlerts(this._repository);

  final AlertRepository _repository;

  Future<Result<ManagedAlertsPage>> call({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) => _repository.getManagedAlerts(
    municipalityId: municipalityId,
    includeExpired: includeExpired,
    cursor: cursor,
  );
}

class GetManagedAlertDetail {
  const GetManagedAlertDetail(this._repository);

  final AlertRepository _repository;

  Future<Result<ManagedAlert>> call({
    required String id,
    required String municipalityId,
  }) => _repository.getById(id: id, municipalityId: municipalityId);
}

class SaveManualAlert {
  const SaveManualAlert(this._repository);

  static const String endBeforeStartCode = 'alert_end_before_start';
  static const String invalidContentCode = 'alert_invalid_content';
  static const String missingMunicipalityCode = 'alert_missing_municipality';

  final AlertRepository _repository;

  Future<Result<ManagedAlert>> call(SaveManualAlertInput input) {
    if (input.municipalityId.trim().isEmpty) {
      return Future.value(
        const Failure(ValidationFailure(message: missingMunicipalityCode)),
      );
    }
    if (input.phenomenon.trim().isEmpty || input.body.es.trim().isEmpty) {
      return Future.value(
        const Failure(ValidationFailure(message: invalidContentCode)),
      );
    }
    if (input.endAt case final end? when end.isBefore(input.startAt)) {
      return Future.value(
        const Failure(ValidationFailure(message: endBeforeStartCode)),
      );
    }
    return input.isEditing
        ? _repository.update(input)
        : _repository.create(input);
  }
}

class DeleteManualAlert {
  const DeleteManualAlert(this._repository);

  final AlertRepository _repository;

  Future<Result<void>> call(ManagedAlert alert) {
    if (!alert.canManage) {
      return Future.value(
        const Failure(ValidationFailure(message: 'alert_aemet_read_only')),
      );
    }
    return _repository.delete(alert.id);
  }
}
