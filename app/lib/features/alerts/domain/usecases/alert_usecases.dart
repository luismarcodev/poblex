import '../../../../core/result/result.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

class GetAlerts {
  const GetAlerts(this._repository);
  final AlertRepository _repository;

  Future<Result<AlertPage>> call({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) => _repository.list(
    municipalityId: municipalityId,
    includeExpired: includeExpired,
    cursor: cursor,
  );
}

class GetAlertDetail {
  const GetAlertDetail(this._repository);
  final AlertRepository _repository;

  Future<Result<MunicipalAlert>> call({
    required String id,
    required String municipalityId,
  }) => _repository.detail(id: id, municipalityId: municipalityId);
}
