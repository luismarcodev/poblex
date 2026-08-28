import '../../../../core/result/result.dart';
import '../entities/managed_facility.dart';
import '../repositories/facility_repository.dart';

class GetManagedFacilities {
  const GetManagedFacilities(this._repository);
  final FacilityRepository _repository;
  Future<Result<ManagedFacilityPage>> call({required String municipalityId}) =>
      _repository.getManagedFacilities(municipalityId: municipalityId);
}

class SaveFacility {
  const SaveFacility(this._repository);
  final FacilityRepository _repository;
  Future<Result<ManagedFacility>> call(SaveFacilityInput input) =>
      input.isEditing ? _repository.update(input) : _repository.create(input);
}

class GetManagedReservations {
  const GetManagedReservations(this._repository);
  final FacilityRepository _repository;
  Future<Result<ManagedReservationPage>> call({
    required String municipalityId,
    String? facilityId,
    String? cursor,
  }) => _repository.getManagedReservations(
    municipalityId: municipalityId,
    facilityId: facilityId,
    cursor: cursor,
  );
}

class CancelManagedReservation {
  const CancelManagedReservation(this._repository);
  final FacilityRepository _repository;
  Future<Result<void>> call({
    required String reservationId,
    required String note,
  }) => _repository.cancelReservation(reservationId: reservationId, note: note);
}
