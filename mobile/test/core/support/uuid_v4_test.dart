import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/core/support/uuid_v4.dart';

void main() {
  test('generateUuidV4 returns valid v4 format', () {
    final value = generateUuidV4();
    expect(isUuidV4(value), isTrue);
  });

  test('generateUuidV4 produces unique values', () {
    final first = generateUuidV4();
    final second = generateUuidV4();
    expect(first, isNot(equals(second)));
  });
}
