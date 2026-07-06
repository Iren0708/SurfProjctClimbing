import 'package:vertical_mobile/features/auth/domain/auth_messages.dart';

abstract final class OtpValidator {
  static final _pattern = RegExp(r'^\d{4,6}$');

  static bool isComplete(String code, {int length = 4}) {
    return code.length == length && _pattern.hasMatch(code);
  }

  static String? validate(String code) {
    if (!_pattern.hasMatch(code)) {
      return AuthMessages.codeInvalid;
    }
    return null;
  }
}
