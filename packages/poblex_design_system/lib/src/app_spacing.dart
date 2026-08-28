import 'package:flutter/material.dart';

abstract final class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double giant = 64;

  static const EdgeInsets screenPadding = EdgeInsets.all(md);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}

abstract final class AppRadius {
  const AppRadius._();

  static const double xs = 4; // severity alerts + fields, reserved shape
  static const double sm = 8;
  static const double md = 12; // buttons
  static const double lg = 16; // cards
  static const double xl = 24; // bottom sheets
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

abstract final class AppSize {
  const AppSize._();

  static const double minTouchTarget = 48;
  static const double comfortableTouchTarget = 56;
  static const double minTouchSeparation = 8;
  static const double bottomNavHeight = 80;

  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconNav = 28;
  static const double iconLg = 32;
  static const double iconIllustration = 48;

  static const double maxContentWidth = 640;
  // Wider column for the backoffice's desktop tables/forms.
  static const double maxWorkspaceWidth = 1280;
  static const double navigationRailWidth = 264;

  static const double focusRingWidth = 3;
  static const double focusRingOffset = 2;
  static const double borderWidth = 2; // fields and outlined buttons
  static const double chipBorderWidth = 1.5; // category chips (R2)
  static const double severityChipBorderWidth = 1.5; // severity chips (R2/R4)
  static const double darkCardBorderWidth = 1;
}

/// Single entry point for animation durations. No widget writes a `Duration`
/// literal by hand — everything goes through [duration] so that reduce-motion
/// (A-43) collapses every animation in the app in exactly one place.
abstract final class AppMotion {
  const AppMotion._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration skeletonSweep = Duration(milliseconds: 1200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasis = Curves.easeOut;

  static Duration duration(BuildContext context, Duration value) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;
  }

  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }
}

abstract final class AppElevation {
  const AppElevation._();

  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 4;
  static const double level3 = 8;

  static List<BoxShadow> cardShadow(Brightness brightness) {
    if (brightness == Brightness.dark) return const <BoxShadow>[];
    return const <BoxShadow>[
      BoxShadow(
        color: Color(0x141A1A1A), // #1A1A1A at 8%
        offset: Offset(0, 1),
        blurRadius: 3,
      ),
    ];
  }

  static List<BoxShadow> sheetShadow(Brightness brightness) {
    if (brightness == Brightness.dark) return const <BoxShadow>[];
    return const <BoxShadow>[
      BoxShadow(
        color: Color(0x1F1A1A1A), // #1A1A1A at 12%
        offset: Offset(0, 4),
        blurRadius: 12,
      ),
    ];
  }

  static List<BoxShadow> dialogShadow(Brightness brightness) {
    if (brightness == Brightness.dark) return const <BoxShadow>[];
    return const <BoxShadow>[
      BoxShadow(
        color: Color(0x291A1A1A), // #1A1A1A at 16%
        offset: Offset(0, 8),
        blurRadius: 24,
      ),
    ];
  }
}

/// Phone-first breakpoints; the wider tier only stops a reading column or a
/// backoffice workspace from stretching past a comfortable measure.
abstract final class AppBreakpoints {
  const AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < compact;
  }
}
