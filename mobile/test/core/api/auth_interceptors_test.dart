import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/interceptors/bearer_auth_interceptor.dart';
import 'package:vertical_mobile/core/api/interceptors/refresh_token_interceptor.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../../support/in_memory_token_storage.dart';

void main() {
  group('BearerAuthInterceptor', () {
    test('adds bearer token for protected paths', () async {
      final storage = InMemoryTokenStorage()
        ..accessToken = 'access-1'
        ..refreshToken = 'refresh-1';

      final options = RequestOptions(path: '/profile');
      await BearerAuthInterceptor(storage).onRequest(
        options,
        _CapturingRequestHandler(),
      );

      expect(options.headers['Authorization'], 'Bearer access-1');
    });

    test('skips bearer for public auth paths', () async {
      final storage = InMemoryTokenStorage()..accessToken = 'access-1';

      final options = RequestOptions(path: '/auth/verify-code');
      await BearerAuthInterceptor(storage).onRequest(
        options,
        _CapturingRequestHandler(),
      );

      expect(options.headers['Authorization'], isNull);
    });
  });

  group('RefreshTokenInterceptor', () {
    test('refreshes tokens and retries request on 401', () async {
      final storage = InMemoryTokenStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'refresh-1';

      var profileCalls = 0;
      var unauthorizedHandled = false;

      final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'));
      final refreshAdapter = DioAdapter(dio: refreshDio);
      refreshDio.httpClientAdapter = refreshAdapter;

      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      dio.interceptors.add(
        RefreshTokenInterceptor(
          refreshDio: refreshDio,
          tokenStorage: storage,
          onUnauthorized: () async {
            unauthorizedHandled = true;
          },
        ),
      );

      refreshAdapter.onPost(
        '/auth/refresh',
        (server) => server.reply(200, {
          'access_token': 'new-access',
          'refresh_token': 'new-refresh',
          'token_type': 'Bearer',
          'expires_in': 900,
        }),
        data: {'refresh_token': 'refresh-1'},
      );

      adapter.onGet(
        '/profile',
        (server) {
          profileCalls += 1;
          server.reply(401, {'code': 'unauthorized'});
        },
      );

      refreshAdapter.onGet(
        '/profile',
        (server) => server.reply(200, {'id': 'client'}),
      );

      final response = await dio.get<Map<String, dynamic>>('/profile');

      expect(response.statusCode, 200);
      expect(storage.accessToken, 'new-access');
      expect(storage.refreshToken, 'new-refresh');
      expect(unauthorizedHandled, isFalse);
      expect(profileCalls, 1);
    });

    test('clears session when refresh returns 401', () async {
      final storage = InMemoryTokenStorage()
        ..accessToken = 'expired-access'
        ..refreshToken = 'invalid-refresh';

      var unauthorizedHandled = false;

      final refreshDio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'));
      final refreshAdapter = DioAdapter(dio: refreshDio);
      refreshDio.httpClientAdapter = refreshAdapter;

      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/v1'));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;

      dio.interceptors.add(
        RefreshTokenInterceptor(
          refreshDio: refreshDio,
          tokenStorage: storage,
          onUnauthorized: () async {
            unauthorizedHandled = true;
            await storage.clear();
          },
        ),
      );

      adapter.onGet(
        '/profile',
        (server) => server.reply(401, {'code': 'unauthorized'}),
      );

      refreshAdapter.onPost(
        '/auth/refresh',
        (server) => server.reply(401, {'code': 'unauthorized'}),
        data: {'refresh_token': 'invalid-refresh'},
      );

      await expectLater(
        dio.get<Map<String, dynamic>>('/profile'),
        throwsA(isA<DioException>()),
      );

      expect(unauthorizedHandled, isTrue);
      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
    });
  });
}

class _CapturingRequestHandler extends RequestInterceptorHandler {}
