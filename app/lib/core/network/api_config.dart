abstract final class ApiConfig {
  const ApiConfig._();

  /// Base URL of the backend, overridable at build time:
  ///
  ///   flutter run --dart-define=POBLEX_API_BASE_URL=http://192.168.1.20:3000
  ///
  /// The default targets the Android emulator, where 10.0.2.2 is the host
  /// machine. Note that Android 10+ blocks cleartext HTTP: the debug-only
  /// network security config allows it for this host and nothing else.
  static const String baseUrl = String.fromEnvironment(
    'POBLEX_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static const String apiPrefix = '/v1';

  /// Hard budget for any single request. A-39 forbids indefinite spinners, and
  /// 15 s is the ceiling the accessibility checklist commits to.
  static const Duration timeout = Duration(seconds: 15);

  static String get apiBaseUrl => '$baseUrl$apiPrefix';
}
