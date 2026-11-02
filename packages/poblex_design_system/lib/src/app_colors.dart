import 'package:flutter/material.dart';

/// Raw, unverified colour ramps. Never referenced from a widget — only
/// [AppTheme] and [AppSemanticColors] read these; everyone else goes through
/// the theme so a colour decision is made once, not scattered.
///
/// Sourced from the "Modern Civic Coral" Material 3 scheme (Stitch,
/// `design/stitch_poblex_civic_connect/modern_civic_coral/DESIGN.md`): the
/// primary ramp anchors on Stitch's `primary` (#AC3509) and
/// `primary-container` (#FF7043) tokens, the accent ramp on Stitch's
/// `tertiary` teal, and the neutral ramp on Stitch's `surface`/`on-surface`
/// family. Every step below that maps to a literal Stitch token says so in
/// its comment; the handful that don't (light tints with no Stitch
/// equivalent) are interpolated within the same hue and are not
/// contrast-critical.
abstract final class AppPalette {
  const AppPalette._();

  static const Color primary50 = Color(0xFFFFEBE5);
  static const Color primary100 = Color(0xFFFFDBD0); // Stitch primary-fixed
  static const Color primary200 = Color(0xFFFFC8B7);
  static const Color primary300 = Color(
    0xFFFFB59F,
  ); // Stitch inverse-primary / primary-fixed-dim — dark action
  static const Color primary400 = Color(0xFFE6A38F); // dark pressed
  static const Color primary500 = Color(
    0xFFFF7043,
  ); // Stitch primary-container — DECORATIVE ONLY, ~2.85:1
  static const Color primary600 = Color(
    0xFF641800,
  ); // Stitch on-primary-container — graphic, 11.9:1
  static const Color primary700 = Color(
    0xFFAC3509,
  ); // Stitch primary — light action, 6.43:1 vs white / 6.10:1 vs bg
  static const Color primary800 = Color(
    0xFF852300,
  ); // Stitch on-primary-fixed-variant — light pressed
  static const Color primary900 = Color(0xFF3A0A00); // Stitch on-primary-fixed

  static const Color accent50 = Color(0xFFE6F6F3);
  static const Color accent100 = Color(0xFF89F5E7); // Stitch tertiary-fixed
  static const Color accent200 = Color(0xFF6BD8CB);
  static const Color accent300 = Color(
    0xFF6BD8CB,
  ); // Stitch tertiary-fixed-dim — dark accent
  static const Color accent400 = Color(0xFF3AADA0); // Stitch tertiary-container
  static const Color accent500 = Color(
    0xFF006A61,
  ); // Stitch tertiary — light accent, 6.17:1
  static const Color accent600 = Color(
    0xFF005049,
  ); // Stitch on-tertiary-fixed-variant
  static const Color accent700 = Color(
    0xFF003B36,
  ); // Stitch on-tertiary-container
  static const Color accent800 = Color(0xFF00201D); // Stitch on-tertiary-fixed

  static const Color neutral0 = Color(
    0xFFFFFFFF,
  ); // Stitch surface-container-lowest
  static const Color neutral50 = Color(
    0xFFF8F9FF,
  ); // Stitch background/surface, light background
  static const Color neutral100 = Color(
    0xFFEFF4FF,
  ); // Stitch surface-container-low
  static const Color neutral200 = Color(0xFFE5EEFF); // Stitch surface-container
  static const Color neutral300 = Color(
    0xFFDCE9FF,
  ); // Stitch surface-container-high
  static const Color neutral400 = Color(
    0xFFD3E4FE,
  ); // Stitch surface-container-highest, disabled icons ONLY
  static const Color neutral500 = Color(0xFF8D7169); // Stitch outline
  static const Color neutral600 = Color(
    0xFF59413A,
  ); // Stitch on-surface-variant — muted text, 8.90:1
  static const Color neutral700 = Color(0xFF4C3731); // secondary text
  static const Color neutral800 = Color(0xFF332D29);
  static const Color neutral900 = Color(
    0xFF0B1C30,
  ); // Stitch on-surface — ink, ~18:1

  static const Color darkBackground = Color(0xFF14110F);
  static const Color darkSurface = Color(0xFF1F1A17); // 1.09:1 vs background
  static const Color darkSurfaceHigh = Color(0xFF2A241F);
  static const Color darkOutline = Color(0xFF7C716A); // 3.96:1
  static const Color darkOutlineSubtle = Color(0xFF4D4642);
  static const Color darkOnSurface = Color(0xFFF5F0E9); // 16.59:1
  static const Color darkOnSurfaceMuted = Color(0xFFBFB8B0); // 9.58:1
  static const Color darkSkeletonHighlight = Color(0xFF37302A);
}

/// AEMET-locked severity hexadecimals. Residents already associate these with
/// the weather bulletin — they are never adjusted for branding, and are
/// deliberately NOT touched by the Stitch-derived rebrand in [AppPalette]:
/// Stitch's own mockup for the alerts screen reused its brand coral
/// (`primary-container`) as the "orange" severity colour, which is exactly
/// the marca/severidad collision `docs/design-system.md` rule R1 forbids.
/// This palette stays as the accessibility-verified source of truth instead.
abstract final class AppSeverityPalette {
  const AppSeverityPalette._();

  static const Color yellowIdentity = Color(0xFFE8A33D);
  static const Color yellowTint = Color(0xFFFCF3E3);
  static const Color yellowDeep = Color(0xFF7D5003);
  static const Color yellowTintDark = Color(0xFF3C3120);
  static const Color yellowBarDark = Color(0xFFE8AB30);
  static const Color yellowOnDark = Color(0xFFF6C96F);

  static const Color orangeIdentity = Color(0xFFD9772B);
  static const Color orangeTint = Color(0xFFFCEBDE);
  static const Color orangeDeep = Color(0xFF862F04);
  static const Color orangeTintDark = Color(0xFF3A271D);
  static const Color orangeBarDark = Color(0xFFEC8B3C);
  static const Color orangeOnDark = Color(0xFFF49E57);

  static const Color redIdentity = Color(0xFFB3261E);
  static const Color redTint = Color(0xFFFCE5E3);
  static const Color redDeep = Color(0xFF92161A);
  static const Color redTintDark = Color(0xFF3D1C1A);
  static const Color redBarDark = Color(0xFFEB5847);
  static const Color redOnDark = Color(0xFFF88277);
}

/// The enum owns the geometric channel (bar width), not just the colour: R3
/// requires the lateral bar to change thickness between levels, because in
/// the dark palette the bar tones alone (2.42 vs 2.35 luminance) are too close
/// to tell apart by colour alone.
enum AlertSeverity {
  yellow(level: 1, barWidth: 4),
  orange(level: 2, barWidth: 8),
  red(level: 3, barWidth: 12);

  const AlertSeverity({required this.level, required this.barWidth});

  final int level;
  final double barWidth;
}

/// Every colour a severity banner needs. Deliberately separate from
/// [AppSemanticColors]'s other fields: nothing here may leak into a
/// non-alert widget (rule R1), and nothing brand-coloured may leak in here.
@immutable
class SeverityColors {
  const SeverityColors({
    required this.identity,
    required this.onIdentity,
    required this.surface,
    required this.onSurface,
    required this.heading,
    required this.bar,
    required this.border,
  });

  /// Solid chip fill — the AEMET colour itself.
  final Color identity;

  /// Chip label colour. White on red; ink on yellow/orange.
  final Color onIdentity;

  /// Banner background (the tint).
  final Color surface;

  /// Banner body text.
  final Color onSurface;

  /// Banner headline.
  final Color heading;

  /// Lateral bar and chip border colour.
  final Color bar;

  /// Banner 1dp border.
  final Color border;

  static SeverityColors lerp(SeverityColors a, SeverityColors b, double t) {
    return SeverityColors(
      identity: Color.lerp(a.identity, b.identity, t)!,
      onIdentity: Color.lerp(a.onIdentity, b.onIdentity, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
      heading: Color.lerp(a.heading, b.heading, t)!,
      bar: Color.lerp(a.bar, b.bar, t)!,
      border: Color.lerp(a.border, b.border, t)!,
    );
  }
}

/// Semantic colours Material's [ColorScheme] does not model. Consumed via
/// `Theme.of(context).extension<AppSemanticColors>()!` — see
/// `theme_context_extension.dart` for the shorthand.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.alertYellow,
    required this.alertOrange,
    required this.alertRed,
    required this.brandDecorative,
    required this.brandGraphic,
    required this.textMuted,
    required this.textSecondary,
    required this.focusRing,
    required this.success,
    required this.onSuccess,
    required this.successSurface,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.sunkenSurface,
    required this.dividerSubtle,
  });

  final SeverityColors alertYellow;
  final SeverityColors alertOrange;
  final SeverityColors alertRed;

  /// `#FF7043` untouched — surfaces and illustration only. ~2.85:1 on white:
  /// never text, never a filled button background.
  final Color brandDecorative;

  /// Icons and borders that carry meaning. >= 3:1.
  final Color brandGraphic;

  final Color textMuted;
  final Color textSecondary;
  final Color focusRing;
  final Color success;
  final Color onSuccess;
  final Color successSurface;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color sunkenSurface;
  final Color dividerSubtle;

  SeverityColors of(AlertSeverity severity) => switch (severity) {
    AlertSeverity.yellow => alertYellow,
    AlertSeverity.orange => alertOrange,
    AlertSeverity.red => alertRed,
  };

  static const AppSemanticColors light = AppSemanticColors(
    alertYellow: SeverityColors(
      identity: AppSeverityPalette.yellowIdentity,
      onIdentity: AppPalette.neutral900,
      surface: AppSeverityPalette.yellowTint,
      onSurface: AppPalette.neutral900,
      heading: AppSeverityPalette.yellowDeep,
      bar: AppSeverityPalette.yellowDeep,
      border: AppSeverityPalette.yellowDeep,
    ),
    alertOrange: SeverityColors(
      identity: AppSeverityPalette.orangeIdentity,
      onIdentity: AppPalette.neutral900,
      surface: AppSeverityPalette.orangeTint,
      onSurface: AppPalette.neutral900,
      heading: AppSeverityPalette.orangeDeep,
      bar: AppSeverityPalette.orangeDeep,
      border: AppSeverityPalette.orangeDeep,
    ),
    alertRed: SeverityColors(
      identity: AppSeverityPalette.redIdentity,
      onIdentity: AppPalette.neutral0,
      surface: AppSeverityPalette.redTint,
      onSurface: AppPalette.neutral900,
      heading: AppSeverityPalette.redDeep,
      bar: AppSeverityPalette.redDeep,
      border: AppSeverityPalette.redDeep,
    ),
    brandDecorative: AppPalette.primary500,
    brandGraphic: AppPalette.primary600,
    textMuted: AppPalette.neutral600,
    textSecondary: AppPalette.neutral700,
    focusRing: AppPalette.primary800,
    success: AppPalette.accent500,
    onSuccess: AppPalette.neutral0,
    successSurface: AppPalette.accent50,
    skeletonBase: AppPalette.neutral200,
    skeletonHighlight: AppPalette.neutral100,
    sunkenSurface: AppPalette.neutral100,
    dividerSubtle: AppPalette.neutral300,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    alertYellow: SeverityColors(
      identity: AppSeverityPalette.yellowBarDark,
      onIdentity: AppPalette.neutral900,
      surface: AppSeverityPalette.yellowTintDark,
      onSurface: AppPalette.darkOnSurface,
      heading: AppSeverityPalette.yellowOnDark,
      bar: AppSeverityPalette.yellowBarDark,
      border: AppSeverityPalette.yellowBarDark,
    ),
    alertOrange: SeverityColors(
      identity: AppSeverityPalette.orangeBarDark,
      onIdentity: AppPalette.neutral900,
      surface: AppSeverityPalette.orangeTintDark,
      onSurface: AppPalette.darkOnSurface,
      heading: AppSeverityPalette.orangeOnDark,
      bar: AppSeverityPalette.orangeBarDark,
      border: AppSeverityPalette.orangeBarDark,
    ),
    alertRed: SeverityColors(
      identity: AppSeverityPalette.redBarDark,
      onIdentity: AppPalette.neutral900,
      surface: AppSeverityPalette.redTintDark,
      onSurface: AppPalette.darkOnSurface,
      heading: AppSeverityPalette.redOnDark,
      bar: AppSeverityPalette.redBarDark,
      border: AppSeverityPalette.redBarDark,
    ),
    brandDecorative: AppPalette.primary500,
    brandGraphic: AppPalette.primary300,
    textMuted: AppPalette.darkOnSurfaceMuted,
    textSecondary: AppPalette.darkOnSurfaceMuted,
    focusRing: AppPalette.primary300,
    success: AppPalette.accent300,
    onSuccess: AppPalette.darkBackground,
    successSurface: AppPalette.darkSurfaceHigh,
    skeletonBase: AppPalette.darkSurfaceHigh,
    skeletonHighlight: AppPalette.darkSkeletonHighlight,
    sunkenSurface: AppPalette.darkBackground,
    dividerSubtle: AppPalette.darkOutlineSubtle,
  );

  @override
  AppSemanticColors copyWith({
    SeverityColors? alertYellow,
    SeverityColors? alertOrange,
    SeverityColors? alertRed,
    Color? brandDecorative,
    Color? brandGraphic,
    Color? textMuted,
    Color? textSecondary,
    Color? focusRing,
    Color? success,
    Color? onSuccess,
    Color? successSurface,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? sunkenSurface,
    Color? dividerSubtle,
  }) {
    return AppSemanticColors(
      alertYellow: alertYellow ?? this.alertYellow,
      alertOrange: alertOrange ?? this.alertOrange,
      alertRed: alertRed ?? this.alertRed,
      brandDecorative: brandDecorative ?? this.brandDecorative,
      brandGraphic: brandGraphic ?? this.brandGraphic,
      textMuted: textMuted ?? this.textMuted,
      textSecondary: textSecondary ?? this.textSecondary,
      focusRing: focusRing ?? this.focusRing,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successSurface: successSurface ?? this.successSurface,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      sunkenSurface: sunkenSurface ?? this.sunkenSurface,
      dividerSubtle: dividerSubtle ?? this.dividerSubtle,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      alertYellow: SeverityColors.lerp(alertYellow, other.alertYellow, t),
      alertOrange: SeverityColors.lerp(alertOrange, other.alertOrange, t),
      alertRed: SeverityColors.lerp(alertRed, other.alertRed, t),
      brandDecorative: Color.lerp(brandDecorative, other.brandDecorative, t)!,
      brandGraphic: Color.lerp(brandGraphic, other.brandGraphic, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(
        skeletonHighlight,
        other.skeletonHighlight,
        t,
      )!,
      sunkenSurface: Color.lerp(sunkenSurface, other.sunkenSurface, t)!,
      dividerSubtle: Color.lerp(dividerSubtle, other.dividerSubtle, t)!,
    );
  }
}

/// Brand seed → verified action colours for one municipality.
///
/// The municipality colour is a SEED, never a token: [fromSeed] anchors
/// lightness/tone through a deterministic loop that guarantees >= 4.5:1, so no
/// manager can break accessibility by picking a bad colour in the backoffice.
@immutable
class BrandPalette {
  const BrandPalette({
    required this.seed,
    required this.decorative,
    required this.graphic,
    required this.lightAction,
    required this.lightActionPressed,
    required this.lightContainer,
    required this.onLightContainer,
    required this.darkAction,
    required this.darkActionPressed,
  });

  final Color seed;
  final Color decorative;
  final Color graphic;
  final Color lightAction;
  final Color lightActionPressed;
  final Color lightContainer;
  final Color onLightContainer;
  final Color darkAction;
  final Color darkActionPressed;

  /// Hand-tuned default sourced straight from Stitch's "Modern Civic Coral"
  /// tokens: `primary-container` (decorative), `on-primary-container`
  /// (graphic), `primary` (light action, 6.43:1 vs white / 6.10:1 vs the new
  /// bone background) and `inverse-primary` (dark action). Verified better
  /// than the loop's ~4.55:1 worst case — see
  /// `brand_palette_contrast_test.dart`.
  static const BrandPalette poblex = BrandPalette(
    seed: AppPalette.primary500,
    decorative: AppPalette.primary500,
    graphic: AppPalette.primary600,
    lightAction: AppPalette.primary700,
    lightActionPressed: AppPalette.primary800,
    lightContainer: AppPalette.primary500,
    onLightContainer: AppPalette.primary600,
    darkAction: AppPalette.primary300,
    darkActionPressed: AppPalette.primary400,
  );

  factory BrandPalette.fromSeed(Color seed) {
    final HSLColor hsl = HSLColor.fromColor(seed);

    final Color lightAction = _darkenUntilReadable(
      hsl,
      background: AppPalette.neutral50,
      foregroundOnFill: AppPalette.neutral0,
    );
    final Color darkAction = _lightenUntilReadable(
      hsl,
      background: AppPalette.darkBackground,
    );

    return BrandPalette(
      seed: seed,
      decorative: seed,
      graphic: _darkenUntilContrast(hsl, AppPalette.neutral50, 3.0),
      lightAction: lightAction,
      lightActionPressed: _shiftLightness(lightAction, -0.08),
      lightContainer: hsl
          .withLightness(0.92)
          .withSaturation(_clamp01(hsl.saturation * 0.9))
          .toColor(),
      onLightContainer: lightAction,
      darkAction: darkAction,
      darkActionPressed: _shiftLightness(darkAction, -0.08),
    );
  }

  /// Contrast against BOTH the bone background and pure white, because the
  /// same colour also fills a button whose label is white.
  static Color _darkenUntilReadable(
    HSLColor hsl, {
    required Color background,
    required Color foregroundOnFill,
    double target = 4.5,
  }) {
    for (int step = 0; step <= 100; step++) {
      final Color candidate = hsl.withLightness(1 - step / 100).toColor();
      if (contrastRatio(candidate, background) >= target &&
          contrastRatio(candidate, foregroundOnFill) >= target) {
        return candidate;
      }
    }
    return const Color(0xFF000000);
  }

  static Color _darkenUntilContrast(
    HSLColor hsl,
    Color background,
    double target,
  ) {
    for (int step = 0; step <= 100; step++) {
      final Color candidate = hsl.withLightness(1 - step / 100).toColor();
      if (contrastRatio(candidate, background) >= target) return candidate;
    }
    return const Color(0xFF000000);
  }

  static Color _lightenUntilReadable(
    HSLColor hsl, {
    required Color background,
    double target = 4.5,
  }) {
    for (int step = 0; step <= 100; step++) {
      final Color candidate = hsl.withLightness(step / 100).toColor();
      if (contrastRatio(candidate, background) >= target) return candidate;
    }
    return const Color(0xFFFFFFFF);
  }

  static Color _shiftLightness(Color color, double delta) {
    final HSLColor hsl = HSLColor.fromColor(color);
    return hsl.withLightness(_clamp01(hsl.lightness + delta)).toColor();
  }

  static double _clamp01(double value) => value.clamp(0.0, 1.0);

  /// WCAG 2.1 relative-luminance contrast ratio. Public so tests — and the
  /// backoffice's "your colour is unreadable" warning — can call it directly.
  static double contrastRatio(Color a, Color b) {
    final double luminanceA = a.computeLuminance();
    final double luminanceB = b.computeLuminance();
    final double lighter = luminanceA > luminanceB ? luminanceA : luminanceB;
    final double darker = luminanceA > luminanceB ? luminanceB : luminanceA;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// For a CI test that walks every municipality seed in the fixtures and
  /// fails the build on a bad colour, instead of finding out in production.
  bool get meetsContrastRequirements =>
      contrastRatio(lightAction, AppPalette.neutral50) >= 4.5 &&
      contrastRatio(lightAction, AppPalette.neutral0) >= 4.5 &&
      contrastRatio(darkAction, AppPalette.darkBackground) >= 4.5 &&
      contrastRatio(graphic, AppPalette.neutral50) >= 3.0;
}
