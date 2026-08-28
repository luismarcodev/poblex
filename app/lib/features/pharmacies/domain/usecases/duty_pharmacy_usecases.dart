import '../../../../core/result/result.dart';
import '../entities/duty_pharmacy.dart';
import '../repositories/duty_pharmacy_repository.dart';

class GetDutyPharmacies {
  const GetDutyPharmacies(this._repository);
  final DutyPharmacyRepository _repository;

  Future<Result<List<DutyPharmacy>>> call({
    required String municipalityId,
    DateTime? from,
    int? days,
  }) =>
      _repository.list(municipalityId: municipalityId, from: from, days: days);
}

class GetTodayDutyPharmacy {
  const GetTodayDutyPharmacy(this._repository);
  final DutyPharmacyRepository _repository;

  Future<Result<DutyPharmacy>> call(String municipalityId) =>
      _repository.today(municipalityId);
}
