import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Sizes an [AppIconBadge] ships with. Custom diameters are deliberately not
/// exposed — three consistent sizes read as "designed"; arbitrary ones read
/// as improvised.
enum AppIconBadgeSize { small, medium, large }

/// A soft, rounded container behind a glyph.
///
/// This is the sanctioned way to put brand colour behind an icon: it uses
/// [ColorScheme.primaryContainer] / [ColorScheme.onPrimaryContainer] by
/// default, which are *already* the accessibility-verified pair from
/// [BrandPalette] (>= 3:1 graphic contrast in both light and dark — see
/// app_colors.dart). It never touches
/// [AppSemanticColors.alertYellow]/`alertOrange`/`alertRed`, so it cannot
/// collide with rule R1 (no brand colour inside a severity container) no
/// matter where a screen puts it.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({
    required this.icon,
    this.size = AppIconBadgeSize.medium,
    this.backgroundColor,
    this.foregroundColor,
    this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final AppIconBadgeSize size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  /// Leave null when the badge sits next to visible text that already
  /// describes it — labelling both would make a screen reader announce the
  /// same thing twice.
  final String? semanticLabel;

  double get _diameter => switch (size) {
    AppIconBadgeSize.small => 36,
    AppIconBadgeSize.medium => 48,
    AppIconBadgeSize.large => 64,
  };

  double get _iconSize => switch (size) {
    AppIconBadgeSize.small => AppSize.iconSm,
    AppIconBadgeSize.medium => AppSize.iconMd,
    AppIconBadgeSize.large => AppSize.iconLg,
  };

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Widget badge = Container(
      width: _diameter,
      height: _diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: _iconSize,
        color: foregroundColor ?? scheme.onPrimaryContainer,
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: badge)
        : Semantics(label: semanticLabel, image: true, child: badge);
  }
}
