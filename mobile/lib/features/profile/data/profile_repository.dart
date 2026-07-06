import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';

class ProfileRepository {
  const ProfileRepository(this._api);

  final VerticalApi _api;

  Future<ClientDto> getProfile() {
    return mapApiCall(() => _api.getProfile());
  }

  Future<ClientDto> updateProfile(String name) {
    return mapApiCall(
      () => _api.updateProfile(UpdateProfileRequest(name: name.trim())),
    );
  }

  Future<void> logout() {
    return mapApiCall(() => _api.logout());
  }

  Future<void> deleteAccount() {
    return mapApiCall(() => _api.deleteAccount());
  }
}
