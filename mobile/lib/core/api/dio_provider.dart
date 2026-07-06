import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/interceptors/bearer_auth_interceptor.dart';
import 'package:vertical_mobile/core/api/interceptors/refresh_token_interceptor.dart';
import 'package:vertical_mobile/core/config/app_config.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';

Dio createDio({
  required String baseUrl,
  required Ref ref,
}) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final refreshDio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(BearerAuthInterceptor(tokenStorage));
  dio.interceptors.add(
    RefreshTokenInterceptor(
      refreshDio: refreshDio,
      tokenStorage: tokenStorage,
      onUnauthorized: () => ref.read(authSessionProvider.notifier).onSessionExpired(),
    ),
  );

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  return createDio(baseUrl: AppConfig.apiBaseUrl, ref: ref);
});
