import 'package:flutter/material.dart';
import 'package:vertical_mobile/app/theme/vertical_spacing.dart';

/// Структурные токены темы (00-foundations §3).
@immutable
class VerticalTokens extends ThemeExtension<VerticalTokens> {
  const VerticalTokens({
    required this.minTouchTarget,
    required this.screenPadding,
    required this.cardRadius,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacingXxl,
  });

  static const defaults = VerticalTokens(
    minTouchTarget: VerticalSpacing.minTouchTarget,
    screenPadding: VerticalSpacing.lg,
    cardRadius: 12,
    spacingXs: VerticalSpacing.xs,
    spacingSm: VerticalSpacing.sm,
    spacingMd: VerticalSpacing.md,
    spacingLg: VerticalSpacing.lg,
    spacingXl: VerticalSpacing.xl,
    spacingXxl: VerticalSpacing.xxl,
  );

  final double minTouchTarget;
  final double screenPadding;
  final double cardRadius;
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;

  @override
  VerticalTokens copyWith({
    double? minTouchTarget,
    double? screenPadding,
    double? cardRadius,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
  }) {
    return VerticalTokens(
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      screenPadding: screenPadding ?? this.screenPadding,
      cardRadius: cardRadius ?? this.cardRadius,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
    );
  }

  @override
  VerticalTokens lerp(ThemeExtension<VerticalTokens>? other, double t) {
    if (other is! VerticalTokens) {
      return this;
    }
    return this;
  }
}

extension VerticalTokensX on BuildContext {
  VerticalTokens get verticalTokens =>
      Theme.of(this).extension<VerticalTokens>() ?? VerticalTokens.defaults;
}
