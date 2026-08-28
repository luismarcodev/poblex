import 'package:dio/dio.dart';

import '../../../../core/network/api_config.dart';
import '../../../../core/network/api_endpoints.dart';

class DeviceRemoteDataSource {
  const DeviceRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> register({
    required String deviceId,
    required String municipalityId,
    required String locale,
    String? fcmToken,
  }) async {
    await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.devices,
          data: <String, dynamic>{
            'municipalityId': municipalityId,
            'locale': locale,
            'fcmToken': ?fcmToken,
          },
          options: Options(headers: <String, String>{'X-Device-Id': deviceId}),
        )
        .timeout(ApiConfig.timeout);
  }

  Future<void> updatePush({
    required String deviceId,
    required String locale,
    String? fcmToken,
  }) async {
    await _dio
        .patch<Map<String, dynamic>>(
          '${ApiEndpoints.device(deviceId)}/push',
          data: <String, dynamic>{'locale': locale, 'fcmToken': ?fcmToken},
          options: Options(headers: <String, String>{'X-Device-Id': deviceId}),
        )
        .timeout(ApiConfig.timeout);
  }
}
