import 'package:dio/dio.dart';
import 'package:vertical_mobile/core/api/models/common_models.dart';

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.error,
  });

  factory ApiException.fromDio(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        statusCode: exception.response?.statusCode,
        error: ApiErrorBody.fromJson(data),
      );
    }

    return ApiException(
      statusCode: exception.response?.statusCode,
      error: ApiErrorBody(
        code: 'internal_error',
        message: exception.message ?? 'Network error',
      ),
    );
  }

  final int? statusCode;
  final ApiErrorBody error;

  @override
  String toString() => 'ApiException($statusCode, ${error.code}: ${error.message})';
}

Future<T> mapApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw ApiException.fromDio(error);
  }
}
