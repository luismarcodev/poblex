import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/alert_model.dart';

class AlertRemoteDataSource {
  const AlertRemoteDataSource(this._dio);
  final Dio _dio;

  Future<AlertPageModel> list({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.alerts,
          queryParameters: <String, dynamic>{
            'municipalityId': municipalityId,
            'includeExpired': includeExpired,
            'cursor': ?cursor,
            'limit': 20,
          },
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing alert page');
    return AlertPageModel.fromJson(data);
  }

  Future<AlertModel> detail({
    required String id,
    required String municipalityId,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .get<Map<String, dynamic>>(
          ApiEndpoints.alertDetail(id),
          queryParameters: <String, dynamic>{'municipalityId': municipalityId},
        )
        .timeout(ApiConfig.timeout);
    final Map<String, dynamic>? data = response.data;
    if (data == null) throw const FormatException('Missing alert');
    return AlertModel.fromJson(data);
  }
}
