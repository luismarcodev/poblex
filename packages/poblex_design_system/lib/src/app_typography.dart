import 'package:flutter/material.dart';

abstract final class AppTypography {
  const AppTypography._();

  /// Must match the family declared in each client's `pubspec.yaml`.
  static const String fontFamily = 'AtkinsonHyperlegible';

  /// If the bundled font ever fails to load, this is what stands between the
  /// user and a condensed system default — the whole point of picking an
  /// accessible face in the first place. The bare name (with the space) covers
  /// a platform that already has the font installed under its published name.
  static const List<String> fontFamilyFallback = <String>[
    'Atkinson Hyperlegible',
    'Verdana',
    'Roboto',
    'SF Pro Text',
  ];

  static const double minBodySize = 15.0;
  static const double minLabelSize = 14.0;
  static const double maxTextScale = 2.0;

  static TextTheme textTheme(Color onSurface) {
    TextStyle style({
      required double size,
      required double height,
      required FontWeight weight,
      double letterSpacing = 0,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: onSurface,
      );
    }

    return TextTheme(
      // Sizes/line-heights already matched Stitch's "Modern Civic Coral"
      // scale almost step for step (both come from the same Atkinson
      // Hyperlegible Next M3 generator) — what Stitch adds is the tracking:
      // negative on big headlines, per its display/headline-lg tokens.
      displaySmall: style(
        size: 36,
        height: 1.22,
        weight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      headlineLarge: style(
        size: 32,
        height: 1.25,
        weight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineMedium: style(
        size: 28,
        height: 1.29,
        weight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      headlineSmall: style(size: 24, height: 1.33, weight: FontWeight.w700),
      titleLarge: style(size: 22, height: 1.36, weight: FontWeight.w700),
      titleMedium: style(size: 20, height: 1.40, weight: FontWeight.w600),
      titleSmall: style(size: 18, height: 1.44, weight: FontWeight.w600),
      bodyLarge: style(size: 18, height: 1.56, weight: FontWeight.w400),
      // Material uses bodyMedium as the implicit style for a bare Text. Keep
      // it at the product's 18 sp base so ordinary explanatory copy cannot
      // silently drop below the accessibility requirement.
      bodyMedium: style(size: 18, height: 1.56, weight: FontWeight.w400),
      bodySmall: style(size: 15, height: 1.47, weight: FontWeight.w400),
      labelLarge: style(
        size: 18,
        height: 1.33,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: style(
        size: 16,
        height: 1.25,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelSmall: style(
        size: 14,
        height: 1.43,
        weight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  /// Canonical way to read the clamped scale outside of `MaterialApp.builder`
  /// (`AppTheme.textScalingBuilder`, which most call sites should prefer).
  static TextScaler clampScaler(BuildContext context) {
    return MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: maxTextScale);
  }
}
