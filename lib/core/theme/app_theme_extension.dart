import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.brandPrimary,
    required this.brandAccent,
    required this.cardBackground,
    required this.offlineBannerColor,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.cardRadius,
    required this.cardElevation,
    required this.categoryChipSelected,
    required this.categoryChipUnselected,
  });

  /// Primary brand colour (used in AppBar, FAB, active tabs)
  final Color brandPrimary;

  /// Accent / secondary colour (CTAs, badges)
  final Color brandAccent;

  /// Background for news cards
  final Color cardBackground;

  /// Background of the offline banner
  final Color offlineBannerColor;

  /// Shimmer base colour
  final Color shimmerBase;

  /// Shimmer highlight colour
  final Color shimmerHighlight;

  /// Border radius on all news cards
  final double cardRadius;

  /// Elevation on all news cards
  final double cardElevation;

  /// Category chip colour when selected
  final Color categoryChipSelected;

  /// Category chip colour when NOT selected
  final Color categoryChipUnselected;

  @override
  AppThemeExtension copyWith({
    Color? brandPrimary,
    Color? brandAccent,
    Color? cardBackground,
    Color? offlineBannerColor,
    Color? shimmerBase,
    Color? shimmerHighlight,
    double? cardRadius,
    double? cardElevation,
    Color? categoryChipSelected,
    Color? categoryChipUnselected,
  }) {
    return AppThemeExtension(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      cardBackground: cardBackground ?? this.cardBackground,
      offlineBannerColor: offlineBannerColor ?? this.offlineBannerColor,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      cardRadius: cardRadius ?? this.cardRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      categoryChipSelected: categoryChipSelected ?? this.categoryChipSelected,
      categoryChipUnselected:
          categoryChipUnselected ?? this.categoryChipUnselected,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      offlineBannerColor: Color.lerp(
        offlineBannerColor,
        other.offlineBannerColor,
        t,
      )!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t),
      categoryChipSelected: Color.lerp(
        categoryChipSelected,
        other.categoryChipSelected,
        t,
      )!,
      categoryChipUnselected: Color.lerp(
        categoryChipUnselected,
        other.categoryChipUnselected,
        t,
      )!,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
