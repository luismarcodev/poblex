import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shorthand for the theme lookups every widget needs.
///
/// Beyond brevity this keeps `Theme.of(context).extension<...>()!` — with its
/// bang — in exactly one file instead of scattered across every widget that
/// needs a severity or brand colour.
extension AppThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  /// Semantic colours Material does not model: severity, skeletons, focus
  /// ring, decorative brand. Non-null because [AppTheme] always registers it.
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
