import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/api_action_error_mapper.dart';
import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';

void main() {
  group('ApiActionErrorMapper', () {
    test('returns API message for 4xx', () {
      final message = ApiActionErrorMapper.map(
        ApiException(
          statusCode: 409,
          error: const ApiErrorBody(
            code: 'conflict',
            message: 'Имя уже занято',
          ),
        ),
      );

      expect(message, 'Имя уже занято');
    });

    test('returns network fallback when status is null', () {
      final message = ApiActionErrorMapper.map(
        ApiException(
          statusCode: null,
          error: const ApiErrorBody(
            code: 'internal_error',
            message: 'Network error',
          ),
        ),
      );

      expect(message, ApiActionErrorMessages.network);
    });

    test('returns server fallback for 5xx', () {
      final message = ApiActionErrorMapper.map(
        ApiException(
          statusCode: 503,
          error: const ApiErrorBody(code: 'internal_error', message: ''),
        ),
      );

      expect(message, ApiActionErrorMessages.server);
    });

    test('uses custom fallback when 4xx message is empty', () {
      final message = ApiActionErrorMapper.map(
        ApiException(
          statusCode: 400,
          error: const ApiErrorBody(code: 'bad_request', message: ''),
        ),
        fallback: 'Custom fallback',
      );

      expect(message, 'Custom fallback');
    });
  });
}
