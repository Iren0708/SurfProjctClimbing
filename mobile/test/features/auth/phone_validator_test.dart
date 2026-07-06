import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/features/auth/domain/phone_validator.dart';

void main() {
  group('PhoneValidator', () {
    test('normalizes 10-digit Russian number', () {
      expect(
        PhoneValidator.toRussianE164('9991234567'),
        '+79991234567',
      );
    });

    test('normalizes 11-digit number starting with 8', () {
      expect(
        PhoneValidator.toRussianE164('89991234567'),
        '+79991234567',
      );
    });

    test('returns null for incomplete number', () {
      expect(PhoneValidator.toRussianE164('999'), isNull);
    });

    test('formats phone for display', () {
      expect(
        PhoneValidator.formatForDisplay('+79991234567'),
        '+7 999 123-45-67',
      );
    });
  });
}
