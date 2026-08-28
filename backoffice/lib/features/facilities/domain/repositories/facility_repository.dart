import '../../../../core/result/result.dart';
import '../entities/managed_facility.dart';

abstract interface class FacilityRepository {
  Future<Result<ManagedFacilityPage>> getManagedFacilities({
    required String municipalityId,
  });

  Future<Result<ManagedFacility>> create(SaveFacilityInput input);
  Future<Result<ManagedFacility>> update(SaveFacilityInput input);

  Future<Result<ManagedReservationPage>> getManagedReservations({
    required String municipalityId,
    String? facilityId,
    String? cursor,
  });

  Future<Result<void>> cancelReservation({
    required String reservationId,
    required String note,
  });
}
