import 'package:vertical_mobile/core/session/session_tokens.dart';

abstract class TokenStorage {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<bool> readProfilePending();

  Future<void> setProfilePending(bool value);

  Future<void> clear();
}

extension TokenStorageSession on TokenStorage {
  Future<void> saveSession(SessionTokens tokens) => saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
}
