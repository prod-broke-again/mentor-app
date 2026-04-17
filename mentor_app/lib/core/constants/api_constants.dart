/// Базовый URL Laravel API (переопределяется через --dart-define).
abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://n1mail.online',
  );
}
