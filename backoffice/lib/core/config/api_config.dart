abstract final class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'POBLEX_API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );
}
