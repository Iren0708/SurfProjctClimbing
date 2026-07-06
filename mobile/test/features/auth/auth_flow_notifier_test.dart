import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/session/auth_session_notifier.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';
import 'package:vertical_mobile/features/auth/data/auth_repository.dart';
import 'package:vertical_mobile/features/auth/data/auth_repository_provider.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_flow_notifier.dart';
import 'package:vertical_mobile/features/auth/presentation/auth_flow_state.dart';

import '../../support/in_memory_token_storage.dart';

void main() {
  group('AuthFlowNotifier', () {
    test('requestCode moves to otp step on success', () async {
      final container = _createContainer(_FakeAuthRepository());

      final notifier = container.read(authFlowProvider.notifier);
      notifier.updatePhoneInput('9991234567');

      final error = await notifier.requestCode();

      expect(error, isNull);
      final state = container.read(authFlowProvider);
      expect(state.step, AuthStep.otp);
      expect(state.e164Phone, '+79991234567');
      expect(state.resendSecondsLeft, 30);
    });

    test('verifyCode for existing user authenticates session', () async {
      final container = _createContainer(_FakeAuthRepository());
      final notifier = container.read(authFlowProvider.notifier);

      notifier.updatePhoneInput('9991234567');
      await notifier.requestCode();
      notifier.updateOtpCode('1234');

      final error = await notifier.verifyCode();

      expect(error, isNull);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.authenticated,
      );
    });

    test('verifyCode for new user opens name step', () async {
      final container = _createContainer(
        _FakeAuthRepository(isNewUser: true),
      );
      final notifier = container.read(authFlowProvider.notifier);

      notifier.updatePhoneInput('9991234567');
      await notifier.requestCode();
      notifier.updateOtpCode('1234');

      final error = await notifier.verifyCode();

      expect(error, isNull);
      expect(container.read(authFlowProvider).step, AuthStep.name);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.pendingProfile,
      );
    });

    test('submitName completes registration', () async {
      final container = _createContainer(
        _FakeAuthRepository(isNewUser: true),
      );
      final notifier = container.read(authFlowProvider.notifier);

      notifier.updatePhoneInput('9991234567');
      await notifier.requestCode();
      notifier.updateOtpCode('1234');
      await notifier.verifyCode();
      notifier.updateName('Ирина');

      final error = await notifier.submitName();

      expect(error, isNull);
      expect(
        container.read(authSessionProvider),
        AuthSessionStatus.authenticated,
      );
    });
  });
}

ProviderContainer _createContainer(AuthRepository repository) {
  return ProviderContainer(
    overrides: [
      tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
      authRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.isNewUser = false});

  final bool isNewUser;

  @override
  Future<RequestCodeResponse> requestCode(String phone) async {
    return const RequestCodeResponse(
      ttlSeconds: 300,
      resendAfterSeconds: 30,
    );
  }

  @override
  Future<VerifyCodeResponse> verifyCode({
    required String phone,
    required String code,
  }) async {
    return VerifyCodeResponse(
      tokens: const TokenPair(
        accessToken: 'access',
        refreshToken: 'refresh',
        tokenType: 'Bearer',
        expiresIn: 900,
      ),
      client: ClientDto(
        id: 'client-id',
        phone: phone,
        createdAt: DateTime.utc(2026, 7, 6),
        name: isNewUser ? null : 'Ирина',
      ),
      isNew: isNewUser,
    );
  }

  @override
  Future<ClientDto> updateProfile(String name) async {
    return ClientDto(
      id: 'client-id',
      phone: '+79991234567',
      name: name,
      createdAt: DateTime.utc(2026, 7, 6),
    );
  }
}
