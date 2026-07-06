import 'package:vertical_mobile/features/auth/domain/auth_messages.dart';

abstract final class NameValidator {
  static String? validate(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty || trimmed.length > 100) {
      return AuthMessages.nameInvalid;
    }
    return null;
  }
}
