/// Ошибка HTTP/API с опциональным телом ответа.
final class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() =>
      'ApiException($statusCode): $message${body != null ? ' — $body' : ''}';
}
