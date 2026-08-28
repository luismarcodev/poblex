import '../../../../core/result/result.dart';
import '../entities/duty_pharmacy.dart';

abstract interface class DutyPharmacyRepository {
  Future<Result<List<DutyPharmacy>>> list({
    required String municipalityId,
    DateTime? from,
    int? days,
  });

  /// May fail with [NotFoundFailure]-shaped [AppFailure] when the town hasn't
  /// registered a duty pharmacy for today — a valid empty state, not an
  /// error to surface as a broken screen.
  Future<Result<DutyPharmacy>> today(String municipalityId);
}
