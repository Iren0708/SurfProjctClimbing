import 'package:flutter_test/flutter_test.dart';
import 'package:vertical_mobile/app/theme/vertical_theme.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';

void main() {
  test('VerticalTheme exposes structural tokens extension', () {
    final theme = VerticalTheme.light();
    final tokens = theme.extension<VerticalTokens>();

    expect(theme.useMaterial3, isTrue);
    expect(tokens, VerticalTokens.defaults);
    expect(tokens?.minTouchTarget, 48);
  });
}
