import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_facility.dart';
import '../../domain/repositories/facility_repository.dart';
import '../datasources/facility_remote_datasource.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  const FacilityRepositoryImpl(this._remote);
  final FacilityRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedFacilityPage>> getManagedFacilities({
    required String municipalityId,
  }) => _capture(
    () => _remote.getManagedFacilities(municipalityId: municipalityId),
  );

  @override
  Future<Result<ManagedFacility>> create(SaveFacilityInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<ManagedFacility>> update(SaveFacilityInput input) =>
      _capture(() => _remote.update(input));

  @override
  Future<Result<ManagedReservationPage>> getManagedReservations({
    required String municipalityId,
    String? facilityId,
    String? cursor,
  }) => _capture(
    () => _remote.getManagedReservations(
      municipalityId: municipalityId,
      facilityId: facilityId,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<void>> cancelReservation({
    required String reservationId,
    required String note,
  }) => _capture(
    () => _remote.cancelReservation(reservationId: reservationId, note: note),
  );
}
