import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';
import 'package:vertical_mobile/core/storage/token_storage.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';

import '../../support/in_memory_token_storage.dart';

void main() {
  group('AuthSessionNotifier', () {
    test('bootstrap sets unauthenticated when refresh token missing', () async {
      final container = _createContainer(InMemoryTokenStorage());

      await container.read(authSessionProvider.notifier).bootstrap();

      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.unauthenticated,
      );
    });

    test('bootstrap sets authenticated when refresh token exists', () async {
      final storage = InMemoryTokenStorage()..refreshToken = 'refresh-1';
      final container = _createContainer(storage);

      await container.read(authSessionProvider.notifier).bootstrap();

      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.authenticated,
      );
    });

    test('onSessionExpired clears tokens and marks unauthenticated', () async {
      final storage = InMemoryTokenStorage()
        ..accessToken = 'access'
        ..refreshToken = 'refresh';
      final container = _createContainer(storage);

      await container.read(authSessionProvider.notifier).onSessionExpired();

      expect(storage.accessToken, isNull);
      expect(storage.refreshToken, isNull);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.unauthenticated,
      );
    });

    test('saveSession stores tokens and marks authenticated', () async {
      final container = _createContainer(InMemoryTokenStorage());
      const tokens = TokenPair(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        tokenType: 'Bearer',
        expiresIn: 900,
      );

      await container.read(authSessionProvider.notifier).saveSession(tokens);

      final storage = container.read(tokenStorageProvider) as InMemoryTokenStorage;
      expect(storage.accessToken, 'access-1');
      expect(storage.refreshToken, 'refresh-1');
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.authenticated,
      );
    });

    test('saveSession with requiresProfile marks pendingProfile', () async {
      final container = _createContainer(InMemoryTokenStorage());
      const tokens = TokenPair(
        accessToken: 'access-1',
        refreshToken: 'refresh-1',
        tokenType: 'Bearer',
        expiresIn: 900,
      );

      await container
          .read(authSessionProvider.notifier)
          .saveSession(tokens, requiresProfile: true);

      final storage = container.read(tokenStorageProvider) as InMemoryTokenStorage;
      expect(storage.profilePending, isTrue);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.pendingProfile,
      );
    });

    test('completeProfile marks authenticated', () async {
      final storage = InMemoryTokenStorage()
        ..refreshToken = 'refresh'
        ..profilePending = true;
      final container = _createContainer(storage);

      await container.read(authSessionProvider.notifier).completeProfile();

      expect(storage.profilePending, isFalse);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.authenticated,
      );
    });
  });
}

ProviderContainer _createContainer(TokenStorage storage) {
  return ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}
