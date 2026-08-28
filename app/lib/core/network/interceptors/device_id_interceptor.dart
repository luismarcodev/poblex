import 'package:dio/dio.dart';

import '../../device/device_id_store.dart';

/// Attaches `X-Device-Id` when the device is already registered.
///
/// It reads but never creates: generating the identifier is an explicit step
/// of onboarding. If a stray request could create it, a device would end up
/// registered without ever having chosen a municipality.
class DeviceIdInterceptor extends Interceptor {
  DeviceIdInterceptor(this._store);

  final DeviceIdStore _store;

  static const String headerName = 'X-Device-Id';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? deviceId = await _store.read();
    if (deviceId != null && deviceId.isNotEmpty) {
      options.headers[headerName] = deviceId;
    }
    handler.next(options);
  }
}
