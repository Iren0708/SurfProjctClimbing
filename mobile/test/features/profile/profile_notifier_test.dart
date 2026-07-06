import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';
import 'package:vertical_mobile/core/storage/token_storage.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';
import 'package:vertical_mobile/core/widgets/loadable_state.dart';
import 'package:vertical_mobile/features/profile/data/profile_repository.dart';
import 'package:vertical_mobile/features/profile/data/profile_repository_provider.dart';
import 'package:vertical_mobile/features/profile/domain/profile_messages.dart';
import 'package:vertical_mobile/features/profile/presentation/profile_notifier.dart';

import '../../support/in_memory_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileNotifier', () {
    test('loads profile on init', () async {
      final container = _createContainer(_FakeProfileRepository());
      addTearDown(container.dispose);

      await container.read(profileProvider.notifier).loadProfile();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(profileProvider);
      expect(state.profile.status, LoadableStatus.content);
      expect(state.profile.data?.name, 'Иван');
    });

    test('validates empty name on save', () async {
      final container = _createContainer(_FakeProfileRepository());
      addTearDown(container.dispose);

      await container.read(profileProvider.notifier).loadProfile();
      await Future<void>.delayed(Duration.zero);

      container.read(profileProvider.notifier).startEditing();
      container.read(profileProvider.notifier).updateDraftName('   ');

      final saved = await container.read(profileProvider.notifier).saveProfile();

      expect(saved, isFalse);
      expect(
        container.read(profileProvider).actionSnack,
        ProfileMessages.nameRequired,
      );
    });

    test('logout clears auth session', () async {
      final storage = InMemoryTokenStorage()
        ..accessToken = 'access'
        ..refreshToken = 'refresh';
      final container = _createContainer(
        _FakeProfileRepository(),
        tokenStorage: storage,
      );
      addTearDown(container.dispose);

      await container.read(authSessionProvider.notifier).bootstrap();

      await container.read(profileProvider.notifier).logout();

      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.unauthenticated,
      );
      expect(storage.refreshToken, isNull);
    });
  });
}

ProviderContainer _createContainer(
  ProfileRepository repository, {
  TokenStorage? tokenStorage,
}) {
  return ProviderContainer(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repository),
      if (tokenStorage != null)
        tokenStorageProvider.overrideWithValue(tokenStorage),
    ],
  );
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<ClientDto> getProfile() async {
    return ClientDto(
      id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      name: 'Иван',
      phone: '+79001234567',
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<ClientDto> updateProfile(String name) async {
    return ClientDto(
      id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
      name: name,
      phone: '+79001234567',
      createdAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {}
}
