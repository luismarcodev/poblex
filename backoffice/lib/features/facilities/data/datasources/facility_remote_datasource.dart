import 'package:dio/dio.dart';

import '../../domain/entities/managed_facility.dart';
import '../models/managed_facility_model.dart';

class FacilityRemoteDataSource {
  const FacilityRemoteDataSource(this._dio);
  final Dio _dio;

  Future<ManagedFacilityPage> getManagedFacilities({
    required String municipalityId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/facilities',
      queryParameters: {'municipalityId': municipalityId},
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing facility list');
    return ManagedFacilityPage(
      items: ManagedFacilityListModel.fromJson(data).items,
    );
  }

  Future<ManagedFacility> create(SaveFacilityInput input) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/facilities',
      data: {
        'municipalityId': input.municipalityId,
        'name': input.name.toJson(),
        'description': ?input.description?.toJson(),
        'category': input.category,
        'slotDurationMinutes': input.slotDurationMinutes,
        'openingHours': _hoursJson(input.openingHours),
        'feeNote': ?input.feeNote?.toJson(),
        'maxAdvanceBookingDays': input.maxAdvanceBookingDays,
      },
    );
    return _entity(response.data);
  }

  Future<ManagedFacility> update(SaveFacilityInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/facilities/${input.id}',
      data: {
        'name': input.name.toJson(),
        'description': input.description?.toJson(),
        'category': input.category,
        'slotDurationMinutes': input.slotDurationMinutes,
        'openingHours': _hoursJson(input.openingHours),
        'feeNote': input.feeNote?.toJson(),
        'maxAdvanceBookingDays': input.maxAdvanceBookingDays,
        'active': input.active,
      },
    );
    return _entity(response.data);
  }

  Future<ManagedReservationPage> getManagedReservations({
    required String municipalityId,
    String? facilityId,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/reservations',
      queryParameters: {
        'municipalityId': municipalityId,
        'facilityId': ?facilityId,
        'cursor': ?cursor,
        'limit': 20,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing reservation page');
    final model = ManagedReservationPageModel.fromJson(data);
    return ManagedReservationPage(
      items: model.items,
      nextCursor: model.nextCursor,
    );
  }

  Future<void> cancelReservation({
    required String reservationId,
    required String note,
  }) => _dio.post<Map<String, dynamic>>(
    '/admin/reservations/$reservationId/cancel',
    data: {'note': note},
  );

  ManagedFacility _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing facility');
    return ManagedFacilityModel.fromJson(data).entity;
  }

  Map<String, dynamic> _hoursJson(Map<String, FacilityDayHours?> hours) => {
    for (final day in facilityDayKeys)
      day: hours[day] == null
          ? null
          : {'open': hours[day]!.open, 'close': hours[day]!.close},
  };
}
