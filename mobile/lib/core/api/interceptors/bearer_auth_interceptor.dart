import 'package:dio/dio.dart';
import 'package:vertical_mobile/core/api/api_paths.dart';
import 'package:vertical_mobile/core/storage/token_storage.dart';

class BearerAuthInterceptor extends Interceptor {
  BearerAuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!ApiPaths.isPublicAuthPath(options.path)) {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }
}
