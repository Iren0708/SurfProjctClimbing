import 'package:dio/dio.dart';
import 'package:vertical_mobile/core/api/api_paths.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/storage/token_storage.dart';

typedef UnauthorizedCallback = Future<void> Function();

class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required this._refreshDio,
    required this._tokenStorage,
    required this._onUnauthorized,
  });

  final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final UnauthorizedCallback _onUnauthorized;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldAttemptRefresh(err)) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleUnauthorized(handler, err);
      return;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiPaths.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      final tokens = TokenPair.fromJson(response.data!);
      await _tokenStorage.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      final retryResponse = await _retryRequest(
        err.requestOptions,
        tokens.accessToken,
      );
      handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      if (refreshError.response?.statusCode == 401) {
        await _handleUnauthorized(handler, err);
        return;
      }
      handler.next(err);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _shouldAttemptRefresh(DioException err) {
    if (err.response?.statusCode != 401) {
      return false;
    }
    final path = err.requestOptions.path;
    if (ApiPaths.isPublicAuthPath(path)) {
      return false;
    }
    if (path.endsWith(ApiPaths.refreshToken)) {
      return false;
    }
    return err.requestOptions.extra['retried_after_refresh'] != true;
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers)
        ..['Authorization'] = 'Bearer $accessToken',
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      extra: Map<String, dynamic>.from(requestOptions.extra)
        ..['retried_after_refresh'] = true,
    );

    return _refreshDio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> _handleUnauthorized(
    ErrorInterceptorHandler handler,
    DioException err,
  ) async {
    await _onUnauthorized();
    handler.next(err);
  }
}
