import 'dart:math';

/// Генерация UUID v4 для Idempotency-Key (R-022).
String generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String segment(int start, int length) {
    return bytes
        .sublist(start, start + length)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  return '${segment(0, 4)}-${segment(4, 2)}-${segment(6, 2)}-'
      '${segment(8, 2)}-${segment(10, 6)}';
}

bool isUuidV4(String value) {
  final pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  );
  return pattern.hasMatch(value);
}
