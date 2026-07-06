import 'package:vertical_mobile/core/api/api_exception.dart';
import 'package:vertical_mobile/core/api/models/auth_models.dart';
import 'package:vertical_mobile/core/api/models/client_models.dart';
import 'package:vertical_mobile/core/api/vertical_api.dart';

class AuthRepository {
  const AuthRepository(this._api);

  final VerticalApi _api;

  Future<RequestCodeResponse> requestCode(String phone) {
    return mapApiCall(
      () => _api.requestAuthCode(RequestCodeRequest(phone: phone)),
    );
  }

  Future<VerifyCodeResponse> verifyCode({
    required String phone,
    required String code,
  }) {
    return mapApiCall(
      () => _api.verifyAuthCode(
        VerifyCodeRequest(phone: phone, code: code),
      ),
    );
  }

  Future<ClientDto> updateProfile(String name) {
    return mapApiCall(
      () => _api.updateProfile(UpdateProfileRequest(name: name.trim())),
    );
  }
}
