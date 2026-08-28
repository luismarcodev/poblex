import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex/features/device/data/datasources/device_remote_datasource.dart';

void main() {
  test(
    'does not clear the stored FCM token when the new token is unavailable',
    () async {
      late RequestOptions request;
      final Dio dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest:
              (RequestOptions options, RequestInterceptorHandler handler) {
                request = options;
                handler.resolve(
                  Response<Map<String, dynamic>>(
                    requestOptions: options,
                    statusCode: 200,
                    data: <String, dynamic>{},
                  ),
                );
              },
        ),
      );

      await DeviceRemoteDataSource(
        dio,
      ).updatePush(deviceId: 'device-id', locale: 'va');

      expect(request.data, <String, dynamic>{'locale': 'va'});
      expect(request.headers['X-Device-Id'], 'device-id');
    },
  );

  test('sends the rotated FCM token when it is available', () async {
    late RequestOptions request;
    final Dio dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          request = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: <String, dynamic>{},
            ),
          );
        },
      ),
    );

    await DeviceRemoteDataSource(
      dio,
    ).updatePush(deviceId: 'device-id', locale: 'es', fcmToken: 'new-token');

    expect(request.data, <String, dynamic>{
      'locale': 'es',
      'fcmToken': 'new-token',
    });
  });
}
