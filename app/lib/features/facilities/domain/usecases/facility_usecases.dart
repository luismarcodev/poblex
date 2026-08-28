import '../../../../core/result/result.dart';
import '../entities/facility.dart';
import '../repositories/facility_repository.dart';

class GetFacilities {
  const GetFacilities(this._repository);
  final FacilityRepository _repository;

  Future<Result<List<Facility>>> call({
    required String municipalityId,
    String? category,
  }) => _repository.list(municipalityId: municipalityId, category: category);
}

class GetFacilityDetail {
  const GetFacilityDetail(this._repository);
  final FacilityRepository _repository;

  Future<Result<Facility>> call(String id) => _repository.detail(id);
}

class GetFacilityAvailability {
  const GetFacilityAvailability(this._repository);
  final FacilityRepository _repository;

  Future<Result<List<AvailabilitySlot>>> call({
    required String facilityId,
    required String date,
  }) => _repository.availability(facilityId: facilityId, date: date);
}

class CreateReservation {
  const CreateReservation(this._repository);
  final FacilityRepository _repository;

  Future<Result<Reservation>> call({
    required String facilityId,
    required DateTime slotStart,
  }) => _repository.reserve(facilityId: facilityId, slotStart: slotStart);
}

class GetMyReservations {
  const GetMyReservations(this._repository);
  final FacilityRepository _repository;

  Future<Result<ReservationPage>> call({String? cursor}) =>
      _repository.listMyReservations(cursor: cursor);
}

class CancelReservation {
  const CancelReservation(this._repository);
  final FacilityRepository _repository;

  Future<Result<void>> call(String reservationId) =>
      _repository.cancel(reservationId);
}
