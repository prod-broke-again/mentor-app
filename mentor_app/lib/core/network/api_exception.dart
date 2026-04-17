import 'dart:convert';

/// Ошибка HTTP/API с опциональным телом ответа и полями валидации Laravel.
final class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.body,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final String? body;
  final Map<String, List<String>>? fieldErrors;

  /// Разбор JSON ответа Laravel (`message`, `errors`).
  factory ApiException.fromHttpBody({
    required int statusCode,
    required String body,
    String fallbackMessage = 'Ошибка запроса',
  }) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return ApiException(fallbackMessage, statusCode: statusCode, body: body);
      }
      final msg = decoded['message'] as String?;
      final errorsRaw = decoded['errors'];
      Map<String, List<String>>? fieldErrors;
      if (errorsRaw is Map<String, dynamic>) {
        fieldErrors = errorsRaw.map((k, v) {
          if (v is List) {
            return MapEntry(k, v.map((e) => e.toString()).toList());
          }
          return MapEntry(k, [v.toString()]);
        });
      }
      final firstField = _firstValidationMessage(fieldErrors);
      final combined = [
        ?msg,
        ?firstField,
      ].nonNulls.where((s) => s.isNotEmpty).join(' ');
      return ApiException(
        combined.isNotEmpty ? combined : fallbackMessage,
        statusCode: statusCode,
        body: body,
        fieldErrors: fieldErrors,
      );
    } catch (_) {
      return ApiException(fallbackMessage, statusCode: statusCode, body: body);
    }
  }

  String? firstErrorForField(String field) {
    final list = fieldErrors?[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  @override
  String toString() =>
      'ApiException($statusCode): $message${body != null ? ' — $body' : ''}';
}

String? _firstValidationMessage(Map<String, List<String>>? fieldErrors) {
  if (fieldErrors == null) return null;
  for (final list in fieldErrors.values) {
    if (list.isNotEmpty) return list.first;
  }
  return null;
}
