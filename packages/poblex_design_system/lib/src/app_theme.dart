// CupertinoPageTransitionsBuilder lives in the Cupertino library, not Material.
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Material 3 themes for Poblex, shared by the resident app and the
/// backoffice.
///
/// Built by hand from the verified tokens. We deliberately do NOT use
/// `ColorScheme.fromSeed`: Material's tonal-palette algorithm produces tones
/// whose contrast we have not measured, and every pair in this file is
/// checked against the WCAG 2.1 formula in
/// docs/design-system-accessibility.md. A generated scheme would silently
/// undo that work.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData light({BrandPalette brand = BrandPalette.poblex}) {
    return _build(
      brightness: Brightness.light,
      brand: brand,
      background: AppPalette.neutral50,
      surface: AppPalette.neutral0,
      onSurface: AppPalette.neutral900,
      outline: AppPalette.neutral500,
      // The municipality's brand has to reach the widgets too, not just the
      // ColorScheme: otherwise a town with its own colour still shows the
      // Poblex purple in every decorative accent. The alert* fields are
      // deliberately NOT touched — severity is immune to branding, which is
      // what keeps rule R1 standing with a foreign brand.
      semantic: AppSemanticColors.light.copyWith(
        brandDecorative: brand.decorative,
        brandGraphic: brand.graphic,
        focusRing: brand.lightActionPressed,
      ),
      pressedAction: brand.lightActionPressed,
      focusRing: brand.lightActionPressed,
      navUnselected: AppPalette.neutral600,
      navIndicator: brand.lightContainer,
      disabledFill: AppPalette.neutral200,
      disabledLabel: AppPalette.neutral500,
      cardBorderColor: null,
    );
  }

  static ThemeData dark({BrandPalette brand = BrandPalette.poblex}) {
    return _build(
      brightness: Brightness.dark,
      brand: brand,
      background: AppPalette.darkBackground,
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkOnSurface,
      outline: AppPalette.darkOutline,
      semantic: AppSemanticColors.dark.copyWith(
        brandDecorative: brand.decorative,
        brandGraphic: brand.graphic,
        focusRing: brand.darkAction,
      ),
      pressedAction: brand.darkActionPressed,
      focusRing: brand.darkAction,
      navUnselected: AppPalette.darkOnSurfaceMuted,
      navIndicator: AppPalette.darkSurfaceHigh,
      disabledFill: AppPalette.darkSurfaceHigh,
      disabledLabel: AppPalette.darkOnSurfaceMuted,
      // `darkSurface` sits at only 1.09:1 against `darkBackground`: the card
      // border is not decorative here, it is what makes a card visible at all.
      cardBorderColor: AppPalette.darkOutline,
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required BrandPalette brand,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Color outline,
    required AppSemanticColors semantic,
    required Color pressedAction,
    required Color focusRing,
    required Color navUnselected,
    required Color navIndicator,
    required Color disabledFill,
    required Color disabledLabel,
    required Color? cardBorderColor,
  }) {
    final bool isLight = brightness == Brightness.light;
    final Color primary = isLight ? brand.lightAction : brand.darkAction;
    final Color onPrimary = isLight
        ? AppPalette.neutral0
        : AppPalette.darkBackground;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isLight
          ? brand.lightContainer
          : AppPalette.darkSurfaceHigh,
      onPrimaryContainer: isLight ? brand.onLightContainer : brand.darkAction,
      secondary: isLight ? AppPalette.accent500 : AppPalette.accent300,
      onSecondary: isLight ? AppPalette.neutral0 : AppPalette.darkBackground,
      secondaryContainer: isLight
          ? AppPalette.accent100
          : AppPalette.darkSurfaceHigh,
      onSecondaryContainer: isLight
          ? AppPalette.accent700
          : AppPalette.accent300,
      error: isLight
          ? AppSeverityPalette.redDeep
          : AppSeverityPalette.redOnDark,
      onError: isLight ? AppPalette.neutral0 : AppPalette.darkBackground,
      errorContainer: isLight
          ? AppSeverityPalette.redTint
          : AppSeverityPalette.redTintDark,
      onErrorContainer: isLight
          ? AppSeverityPalette.redDeep
          : AppSeverityPalette.redOnDark,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: isLight
          ? AppPalette.neutral100
          : AppPalette.darkSurfaceHigh,
      onSurfaceVariant: semantic.textMuted,
      outline: outline,
      outlineVariant: isLight
          ? AppPalette.neutral300
          : AppPalette.darkOutlineSubtle,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      inverseSurface: onSurface,
      onInverseSurface: surface,
      inversePrimary: isLight ? brand.darkAction : brand.lightAction,
    );

    final TextTheme textTheme = AppTypography.textTheme(onSurface);
    final OutlineInputBorder inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.smAll,
      borderSide: BorderSide(color: outline, width: AppSize.borderWidth),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      fontFamily: AppTypography.fontFamily,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      focusColor: focusRing,
      splashFactory: InkRipple.splashFactory,
      extensions: <ThemeExtension<dynamic>>[semantic],

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primary,
        iconTheme: IconThemeData(color: primary, size: AppSize.iconMd),
        actionsIconTheme: IconThemeData(color: primary, size: AppSize.iconMd),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall?.copyWith(color: primary),
        toolbarHeight: 64,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(AppSize.minTouchTarget, AppSize.comfortableTouchTarget),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
          backgroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) return disabledFill;
            if (states.contains(WidgetState.pressed)) return pressedAction;
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) return disabledLabel;
            return scheme.onPrimary;
          }),
          side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            return states.contains(WidgetState.focused)
                ? BorderSide(color: focusRing, width: AppSize.focusRingWidth)
                : null;
          }),
          elevation: const WidgetStatePropertyAll<double>(0),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(AppSize.minTouchTarget, AppSize.minTouchTarget),
          ),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.disabled)
                ? disabledLabel
                : primary;
          }),
          side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                color: disabledLabel,
                width: AppSize.borderWidth,
              );
            }
            if (states.contains(WidgetState.focused)) {
              return BorderSide(
                color: focusRing,
                width: AppSize.focusRingWidth,
              );
            }
            return BorderSide(color: primary, width: AppSize.borderWidth);
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(AppSize.minTouchTarget, AppSize.minTouchTarget),
          ),
          textStyle: WidgetStatePropertyAll<TextStyle?>(textTheme.labelLarge),
          foregroundColor: WidgetStateProperty.resolveWith((
            Set<WidgetState> states,
          ) {
            return states.contains(WidgetState.disabled)
                ? disabledLabel
                : primary;
          }),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size.square(AppSize.minTouchTarget),
          ),
          iconSize: const WidgetStatePropertyAll<double>(AppSize.iconMd),
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: isLight ? AppElevation.level1 : AppElevation.level0,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: cardBorderColor == null
              ? BorderSide.none
              : BorderSide(
                  color: cardBorderColor,
                  width: AppSize.darkCardBorderWidth,
                ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: semantic.sunkenSurface,
        constraints: const BoxConstraints(
          minHeight: AppSize.comfortableTouchTarget,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: textTheme.titleSmall,
        hintStyle: textTheme.bodyLarge?.copyWith(color: semantic.textMuted),
        helperMaxLines: 4,
        errorMaxLines: 4,
        errorStyle: textTheme.bodyMedium?.copyWith(color: scheme.error),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: AppSize.focusRingWidth),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: scheme.error,
            width: AppSize.borderWidth,
          ),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: scheme.error,
            width: AppSize.focusRingWidth,
          ),
        ),
      ),

      // Outlined by rule R2: solid fill is reserved for severity. Category
      // chips never get a coloured background.
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: scheme.primaryContainer,
        disabledColor: disabledFill,
        labelStyle: textTheme.labelMedium?.copyWith(color: primary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
        side: BorderSide(color: primary, width: AppSize.chipBorderWidth),
        shape: const StadiumBorder(),
        showCheckmark: true,
        checkmarkColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),

      // Kept for any Material NavigationBar a consumer chooses to use, but
      // the resident app navigates through AppDrawer exclusively (no bottom
      // bar) — see app/lib/shared/presentation/app_shell.dart.
      navigationBarTheme: NavigationBarThemeData(
        height: AppSize.bottomNavHeight,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: navIndicator,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return IconThemeData(
            size: AppSize.iconNav,
            color: states.contains(WidgetState.selected)
                ? primary
                : navUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          final bool selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? primary : navUnselected,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
      ),

      // Backoffice's side rail on wide screens.
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: navIndicator,
        indicatorShape: const StadiumBorder(),
        selectedIconTheme: IconThemeData(color: primary, size: AppSize.iconNav),
        unselectedIconTheme: IconThemeData(
          color: navUnselected,
          size: AppSize.iconNav,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: primary),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: navUnselected,
        ),
        minWidth: 88,
        minExtendedWidth: AppSize.navigationRailWidth,
      ),

      dividerTheme: DividerThemeData(
        color: semantic.dividerSubtle,
        thickness: 1,
        space: 1,
      ),

      iconTheme: IconThemeData(color: onSurface, size: AppSize.iconMd),

      listTileTheme: ListTileThemeData(
        minTileHeight: AppSize.comfortableTouchTarget,
        iconColor: onSurface,
        textColor: onSurface,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        showDragHandle: true,
        dragHandleColor: outline,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyLarge,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),

      radioTheme: RadioThemeData(
        visualDensity: VisualDensity.standard,
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return states.contains(WidgetState.disabled)
              ? disabledLabel
              : primary;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        visualDensity: VisualDensity.standard,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return disabledFill;
          return states.contains(WidgetState.selected) ? primary : null;
        }),
      ),

      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) return disabledFill;
          return states.contains(WidgetState.selected)
              ? primary
              : semantic.sunkenSurface;
        }),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: semantic.skeletonBase,
        circularTrackColor: semantic.skeletonBase,
      ),

      // Plain fade, no horizontal travel. With reduce-motion on, the framework
      // collapses the duration; AppMotion.duration covers everything else.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Wraps the app so that the text scale is clamped in exactly one place.
  ///
  /// Put this in `MaterialApp.builder`. It clamps at 200% — the maximum we
  /// commit to supporting — and never below.
  static Widget textScalingBuilder(BuildContext context, Widget? child) {
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1.0,
      maxScaleFactor: AppTypography.maxTextScale,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
