import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/duty_pharmacy_model.dart';

class DutyPharmacyRemoteDataSource {
  const DutyPharmacyRemoteDataSource(this._dio);
  final Dio _dio;

  Future<List<DutyPharmacyModel>> list({
    required String municipalityId,
    DateTime? from,
    int? days,
  }) async {
    final Response<List<dynamic>> response = await _dio
        .get<List<dynamic>>(
          ApiEndpoints.pharmaciesDuty,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'from': ?from?.toIso8601String(),
            'days': ?days,
          },
        )
        .timeout(ApiConfig.timeout);
    final List<dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing pharmacy list');
    return data
        .whereType<Map<String, dynamic>>()
        .map(DutyPharmacyModel.fromJson)
        .toList(growable: false);
  }

  Future<DutyPharmacyModel> today(String municipalityId) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.pharmaciesDutyToday,
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing pharmacy');
    return DutyPharmacyModel.fromJson(data);
  }
}
