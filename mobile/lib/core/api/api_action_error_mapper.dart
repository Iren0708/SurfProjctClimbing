import 'package:vertical_mobile/core/api/api_exception.dart';

/// Тексты ошибок действий (LOGIC-008 §6 — снеки на мутации).
abstract final class ApiActionErrorMessages {
  static const generic = 'Не удалось выполнить. Попробуйте ещё раз.';
  static const network =
      'Не удалось выполнить. Проверьте соединение и повторите.';
  static const server = 'Что-то пошло не так. Попробуйте ещё раз позже.';
}

/// Маппинг ApiException → текст снека для action-запросов (4xx/5xx/сеть).
abstract final class ApiActionErrorMapper {
  const ApiActionErrorMapper._();

  static String map(
    ApiException exception, {
    String fallback = ApiActionErrorMessages.generic,
    String networkFallback = ApiActionErrorMessages.network,
    String serverFallback = ApiActionErrorMessages.server,
  }) {
    final statusCode = exception.statusCode;
    if (statusCode == null) {
      return networkFallback;
    }
    if (statusCode >= 500) {
      return serverFallback;
    }
    final message = exception.error.message.trim();
    if (message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
