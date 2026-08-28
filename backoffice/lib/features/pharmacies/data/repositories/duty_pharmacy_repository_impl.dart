import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../../domain/repositories/duty_pharmacy_repository.dart';
import '../datasources/duty_pharmacy_remote_datasource.dart';

class DutyPharmacyRepositoryImpl implements DutyPharmacyRepository {
  const DutyPharmacyRepositoryImpl(this._remote);

  final DutyPharmacyRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<List<DutyPharmacy>>> getInRange({
    required String municipalityId,
    required DateTime from,
    required int days,
  }) => _capture(
    () => _remote.getInRange(
      municipalityId: municipalityId,
      from: from,
      days: days,
    ),
  );

  @override
  Future<Result<DutyPharmacy>> upsert({
    required String municipalityId,
    required SaveDutyPharmacyInput input,
  }) => _capture(
    () => _remote.upsert(municipalityId: municipalityId, input: input),
  );
}
