import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../device/device_id_store.dart';
import '../l10n/app_locales.dart';
import 'api_config.dart';
import 'interceptors/accept_language_interceptor.dart';
import 'interceptors/device_id_interceptor.dart';

/// Builds the single Dio instance the whole app shares.
Dio buildDioClient({
  required DeviceIdStore deviceIdStore,
  required AppLocale Function() currentLocale,
}) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.apiBaseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      sendTimeout: ApiConfig.timeout,
      // Non-2xx responses come back as DioException so the error mapper is the
      // only place that inspects status codes.
      responseType: ResponseType.json,
      headers: <String, String>{'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    DeviceIdInterceptor(deviceIdStore),
    AcceptLanguageInterceptor(currentLocale),
  ]);

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // The device identifier is not a secret, but it does identify a
        // person's device across sessions: it stays out of the logs.
        requestHeader: false,
        logPrint: (Object? object) => debugPrint('$object'),
      ),
    );
  }

  return dio;
}
