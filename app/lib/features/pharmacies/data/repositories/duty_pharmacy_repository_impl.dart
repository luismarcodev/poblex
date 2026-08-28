import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../../domain/repositories/duty_pharmacy_repository.dart';
import '../datasources/duty_pharmacy_remote_datasource.dart';
import '../mappers/duty_pharmacy_mapper.dart';

class DutyPharmacyRepositoryImpl implements DutyPharmacyRepository {
  const DutyPharmacyRepositoryImpl(this._remote);
  final DutyPharmacyRemoteDataSource _remote;

  @override
  Future<Result<List<DutyPharmacy>>> list({
    required String municipalityId,
    DateTime? from,
    int? days,
  }) async {
    try {
      final result = await _remote.list(
        municipalityId: municipalityId,
        from: from,
        days: days,
      );
      return Success<List<DutyPharmacy>>(
        result.map(DutyPharmacyMapper.toDomain).toList(growable: false),
      );
    } on Object catch (error) {
      return Failed<List<DutyPharmacy>>(mapDioError(error));
    }
  }

  @override
  Future<Result<DutyPharmacy>> today(String municipalityId) async {
    try {
      return Success<DutyPharmacy>(
        DutyPharmacyMapper.toDomain(await _remote.today(municipalityId)),
      );
    } on Object catch (error) {
      return Failed<DutyPharmacy>(mapDioError(error));
    }
  }
}
