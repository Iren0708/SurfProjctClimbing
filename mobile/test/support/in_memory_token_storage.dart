import 'package:vertical_mobile/core/storage/token_storage.dart';

class InMemoryTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;
  bool profilePending = false;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    profilePending = false;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<bool> readProfilePending() async => profilePending;

  @override
  Future<void> setProfilePending(bool value) async {
    profilePending = value;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }
}
