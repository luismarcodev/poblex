import 'package:dio/dio.dart';

import '../../l10n/app_locales.dart';

/// Sends `Accept-Language` on every request.
///
/// The server always returns the full `{es, va}` object and lets the client
/// choose, which is what makes the manual language switch possible. The header
/// is still sent because the API contract asks for it and because targeted
/// pushes are resolved server-side from the stored device locale.
class AcceptLanguageInterceptor extends Interceptor {
  AcceptLanguageInterceptor(this._currentLocale);

  /// Read lazily: the user can switch language while the app is running.
  final AppLocale Function() _currentLocale;

  static const String headerName = 'Accept-Language';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers[headerName] = switch (_currentLocale()) {
      AppLocale.es => 'es-ES,es;q=0.9',
      AppLocale.va => 'ca-ES,ca;q=0.9,es;q=0.8',
    };
    handler.next(options);
  }
}
