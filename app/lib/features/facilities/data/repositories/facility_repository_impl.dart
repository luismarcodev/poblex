import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/facility.dart';
import '../../domain/repositories/facility_repository.dart';
import '../datasources/facility_remote_datasource.dart';
import '../mappers/facility_mapper.dart';
import '../models/facility_model.dart';

class FacilityRepositoryImpl implements FacilityRepository {
  const FacilityRepositoryImpl(this._remote);
  final FacilityRemoteDataSource _remote;

  @override
  Future<Result<List<Facility>>> list({
    required String municipalityId,
    String? category,
  }) async {
    try {
      final FacilityListModel page = await _remote.list(
        municipalityId: municipalityId,
        category: category,
      );
      return Success<List<Facility>>(
        page.items.map(FacilityMapper.toDomain).toList(growable: false),
      );
    } on Object catch (error) {
      return Failed<List<Facility>>(mapDioError(error));
    }
  }

  @override
  Future<Result<Facility>> detail(String id) async {
    try {
      return Success<Facility>(
        FacilityMapper.toDomain(await _remote.detail(id)),
      );
    } on Object catch (error) {
      return Failed<Facility>(mapDioError(error));
    }
  }

  @override
  Future<Result<List<AvailabilitySlot>>> availability({
    required String facilityId,
    required String date,
  }) async {
    try {
      final FacilityAvailabilityModel result = await _remote.availability(
        facilityId: facilityId,
        date: date,
      );
      return Success<List<AvailabilitySlot>>(
        result.slots.map(FacilityMapper.toSlotDomain).toList(growable: false),
      );
    } on Object catch (error) {
      return Failed<List<AvailabilitySlot>>(mapDioError(error));
    }
  }

  @override
  Future<Result<Reservation>> reserve({
    required String facilityId,
    required DateTime slotStart,
  }) async {
    try {
      return Success<Reservation>(
        FacilityMapper.toReservationDomain(
          await _remote.reserve(facilityId: facilityId, slotStart: slotStart),
        ),
      );
    } on Object catch (error) {
      return Failed<Reservation>(mapDioError(error));
    }
  }

  @override
  Future<Result<ReservationPage>> listMyReservations({String? cursor}) async {
    try {
      final ReservationPageModel page = await _remote.listMine(cursor: cursor);
      return Success<ReservationPage>(
        ReservationPage(
          items: page.items
              .map(FacilityMapper.toReservationDomain)
              .toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<ReservationPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<void>> cancel(String reservationId) async {
    try {
      await _remote.cancel(reservationId);
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }
}
