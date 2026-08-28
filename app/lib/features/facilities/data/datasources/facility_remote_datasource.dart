import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/facility_model.dart';

class FacilityRemoteDataSource {
  const FacilityRemoteDataSource(this._dio);
  final Dio _dio;

  Future<FacilityListModel> list({
    required String municipalityId,
    String? category,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.facilities,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'category': ?category,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing facility list');
    return FacilityListModel.fromJson(data);
  }

  Future<FacilityModel> detail(String id) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(ApiEndpoints.facilityDetail(id))
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing facility');
    return FacilityModel.fromJson(data);
  }

  Future<FacilityAvailabilityModel> availability({
    required String facilityId,
    required String date,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.facilityAvailability(facilityId),
          queryParameters: <String, dynamic>{'date': date},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) {
      throw const FormatException('Missing facility availability');
    }
    return FacilityAvailabilityModel.fromJson(data);
  }

  Future<ReservationModel> reserve({
    required String facilityId,
    required DateTime slotStart,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.reservations,
          data: <String, dynamic>{
            'facilityId': facilityId,
            'slotStart': slotStart.toIso8601String(),
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing reservation');
    return ReservationModel.fromJson(data);
  }

  Future<ReservationPageModel> listMine({String? cursor}) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.reservations,
          queryParameters: <String, dynamic>{'cursor': ?cursor, 'limit': 20},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing reservation page');
    return ReservationPageModel.fromJson(data);
  }

  Future<void> cancel(String reservationId) async {
    await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.reservationCancel(reservationId),
        )
        .timeout(ApiConfig.timeout);
  }
}
