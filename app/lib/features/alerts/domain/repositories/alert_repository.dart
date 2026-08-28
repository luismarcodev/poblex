import '../../../../core/result/result.dart';
import '../entities/alert.dart';

abstract interface class AlertRepository {
  Future<Result<AlertPage>> list({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  });

  Future<Result<MunicipalAlert>> detail({
    required String id,
    required String municipalityId,
  });
}
