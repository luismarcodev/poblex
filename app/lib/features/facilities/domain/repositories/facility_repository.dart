import '../../../../core/result/result.dart';
import '../entities/facility.dart';

abstract interface class FacilityRepository {
  Future<Result<List<Facility>>> list({
    required String municipalityId,
    String? category,
  });

  Future<Result<Facility>> detail(String id);

  Future<Result<List<AvailabilitySlot>>> availability({
    required String facilityId,
    required String date,
  });

  Future<Result<Reservation>> reserve({
    required String facilityId,
    required DateTime slotStart,
  });

  Future<Result<ReservationPage>> listMyReservations({String? cursor});

  Future<Result<void>> cancel(String reservationId);
}
