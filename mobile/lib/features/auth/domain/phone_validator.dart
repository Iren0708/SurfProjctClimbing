import 'package:vertical_mobile/features/auth/domain/auth_messages.dart';

abstract final class PhoneValidator {
  static final _e164 = RegExp(r'^\+[1-9]\d{1,14}$');

  static String? validateE164(String? phone) {
    final value = phone?.trim();
    if (value == null || value.isEmpty) {
      return AuthMessages.phoneRequired;
    }
    if (!_e164.hasMatch(value)) {
      return AuthMessages.phoneInvalid;
    }
    return null;
  }

  /// Нормализует ввод пользователя в E.164 для РФ (+7XXXXXXXXXX).
  static String? toRussianE164(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return null;
    }

    String normalized;
    if (digits.length == 11 && digits.startsWith('8')) {
      normalized = '7${digits.substring(1)}';
    } else if (digits.length == 11 && digits.startsWith('7')) {
      normalized = digits;
    } else if (digits.length == 10) {
      normalized = '7$digits';
    } else {
      return null;
    }

    final e164 = '+$normalized';
    return _e164.hasMatch(e164) ? e164 : null;
  }

  static String formatForDisplay(String e164Phone) {
    final digits = e164Phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11 || !digits.startsWith('7')) {
      return e164Phone;
    }
    final local = digits.substring(1);
    return '+7 ${local.substring(0, 3)} ${local.substring(3, 6)}-'
        '${local.substring(6, 8)}-${local.substring(8)}';
  }
}
