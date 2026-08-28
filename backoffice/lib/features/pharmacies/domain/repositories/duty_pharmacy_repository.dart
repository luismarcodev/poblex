import '../../../../core/result/result.dart';
import '../entities/duty_pharmacy.dart';

abstract interface class DutyPharmacyRepository {
  Future<Result<List<DutyPharmacy>>> getInRange({
    required String municipalityId,
    required DateTime from,
    required int days,
  });

  Future<Result<DutyPharmacy>> upsert({
    required String municipalityId,
    required SaveDutyPharmacyInput input,
  });
}
