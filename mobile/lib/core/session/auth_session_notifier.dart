import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/session/auth_session_status.dart';
import 'package:vertical_mobile/core/storage/token_storage.dart';
import 'package:vertical_mobile/core/storage/token_storage_provider.dart';

class AuthSessionNotifier extends Notifier<AuthSessionStatus> {
  @override
  AuthSessionStatus build() => AuthSessionStatus.unknown;

  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  Future<void> bootstrap() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      state = AuthSessionStatus.unauthenticated;
      return;
    }

    final profilePending = await _tokenStorage.readProfilePending();
    state = profilePending
        ? AuthSessionStatus.pendingProfile
        : AuthSessionStatus.authenticated;
  }

  Future<void> saveSession(
    TokenPair tokens, {
    bool requiresProfile = false,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await _tokenStorage.setProfilePending(requiresProfile);
    state = requiresProfile
        ? AuthSessionStatus.pendingProfile
        : AuthSessionStatus.authenticated;
  }

  Future<void> completeProfile() async {
    await _tokenStorage.setProfilePending(false);
    state = AuthSessionStatus.authenticated;
  }

  Future<void> onSessionExpired() async {
    await _tokenStorage.clear();
    state = AuthSessionStatus.unauthenticated;
  }

  Future<void> logout() async {
    await onSessionExpired();
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionStatus>(
  AuthSessionNotifier.new,
);
