import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../session/auth_session.dart';
import 'configure_http_adapter.dart';

class ApiClient {
  ApiClient(this._session) {
    dio = _createDio();
    _refreshDio = _createDio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _session.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: _handleError,
      ),
    );
  }

  final AuthSession _session;
  late final Dio dio;
  late final Dio _refreshDio;
  Future<String?>? _refreshing;

  Dio _createDio() {
    final instance = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );
    configureHttpAdapter(instance);
    return instance;
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final path = error.requestOptions.path;
    final isAuthEndpoint = path.contains('/admin/auth/');
    final alreadyRetried = error.requestOptions.extra['retried'] == true;
    if (error.response?.statusCode != 401 || isAuthEndpoint || alreadyRetried) {
      handler.next(error);
      return;
    }

    try {
      _refreshing ??= _refreshAccessToken();
      final token = await _refreshing;
      _refreshing = null;
      if (token == null) {
        _session.clear();
        handler.next(error);
        return;
      }

      final request = error.requestOptions;
      request.headers['Authorization'] = 'Bearer $token';
      request.extra['retried'] = true;
      handler.resolve(await dio.fetch<dynamic>(request));
    } catch (_) {
      _refreshing = null;
      _session.clear();
      handler.next(error);
    }
  }

  Future<String?> _refreshAccessToken() async {
    final response = await _refreshDio.post<Map<String, dynamic>>(
      '/admin/auth/refresh',
    );
    final token = response.data?['accessToken'];
    if (token is! String) return null;
    _session.updateAccessToken(token);
    return token;
  }
}
