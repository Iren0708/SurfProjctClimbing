import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_colors.dart';
import 'package:vertical_mobile/app/theme/vertical_spacing.dart';
import 'package:vertical_mobile/app/theme/vertical_tokens.dart';

/// Тема Material 3 по структурным токенам (00-foundations §3).
abstract final class VerticalTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: VerticalColors.seed,
      brightness: Brightness.light,
    );

    final textTheme = _textTheme(colorScheme);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: VerticalSpacing.minTouchTarget + VerticalSpacing.lg,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(VerticalSpacing.minTouchTarget),
          textStyle: textTheme.titleMedium,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(VerticalSpacing.minTouchTarget),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VerticalTokens.defaults.cardRadius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
      extensions: const [VerticalTokens.defaults],
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final base = Typography.material2021().black.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        );

    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 15,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
