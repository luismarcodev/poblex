import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../core/l10n/app_locales.dart';
import '../../core/session/session_view_model.dart';
import '../../core/session/session_state.dart';
import '../../features/alerts/domain/entities/alert.dart';
import '../../features/alerts/presentation/viewmodels/alerts_view_model.dart';
import '../../features/alerts/presentation/widgets/severity_presentation.dart';
import '../../features/news/domain/entities/news_item.dart';
import '../../features/news/presentation/viewmodels/news_view_model.dart';
import '../../l10n/app_localizations.dart';
import '../domain/value_objects/localized_text.dart';
import 'app_drawer.dart';

class _Section {
  const _Section({
    required this.icon,
    required this.label,
    required this.description,
    required this.path,
  });

  final IconData icon;
  final String label;
  final String description;
  final String path;
}

/// The aggregator: every one of the eight sections is one tap away from here,
/// which is what keeps the whole app within the two-level navigation depth
/// (A-33).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String municipality =
        ref.watch(
          sessionViewModelProvider.select(
            (AsyncValue<SessionState> value) => value.value?.municipalityName,
          ),
        ) ??
        l10n.appName;

    // .valueOrNull, nunca .when: si la carga de alertas falla o tarda, el
    // banner simplemente no aparece — Home nunca depende de que este
    // provider tenga éxito (regla de "nunca pantalla en blanco").
    final AsyncValue<AlertsUiState> alertsState = ref.watch(
      alertsViewModelProvider,
    );
    final List<MunicipalAlert> activeRedAlerts =
        alertsState.valueOrNull?.items
            .where(
              (MunicipalAlert alert) =>
                  alert.severity == AlertSeverityLevel.red &&
                  alert.isActiveAt(DateTime.now()),
            )
            .toList(growable: false) ??
        const <MunicipalAlert>[];

    // Same fail-silent pattern as the alerts banner: no news, no image, no
    // hero — Home never blocks on this succeeding.
    final NewsUiState? newsState = ref.watch(newsViewModelProvider).valueOrNull;
    final List<NewsItem> newsWithImages = <NewsItem>[
      ...?newsState?.pinned,
      ...?newsState?.items,
    ].where((NewsItem item) => item.imageUrl != null).toList(growable: false);
    final NewsItem? latestNewsWithImage = newsWithImages.isEmpty
        ? null
        : newsWithImages.first;
    final locale = ref.watch(sessionViewModelProvider).valueOrNull?.locale;

    // "Avisos" (report an issue) gets the featured wide card — it's the one
    // action a vecino is most likely to arrive at Home specifically to do.
    // Duty pharmacies gets its own wide CTA at the bottom, same treatment
    // Stitch's mockup gives it. Everything else is a compact grid tile.
    final _Section featured = _Section(
      icon: Icons.report_problem_outlined,
      label: l10n.sectionIncidents,
      description: l10n.sectionIncidentsDescription,
      path: '/incidents',
    );
    final _Section pharmacies = _Section(
      icon: Icons.local_pharmacy_outlined,
      label: l10n.sectionPharmacies,
      description: l10n.sectionPharmaciesDescription,
      path: '/pharmacies',
    );
    final List<_Section> gridSections = <_Section>[
      _Section(
        icon: Icons.newspaper_outlined,
        label: l10n.sectionNews,
        description: l10n.sectionNewsDescription,
        path: '/news',
      ),
      _Section(
        icon: Icons.warning_amber_outlined,
        label: l10n.sectionAlerts,
        description: l10n.sectionAlertsDescription,
        path: '/alerts',
      ),
      _Section(
        icon: Icons.event_outlined,
        label: l10n.sectionEvents,
        description: l10n.sectionEventsDescription,
        path: '/events',
      ),
      _Section(
        icon: Icons.poll_outlined,
        label: l10n.sectionSurveys,
        description: l10n.sectionSurveysDescription,
        path: '/surveys',
      ),
      _Section(
        icon: Icons.description_outlined,
        label: l10n.sectionForms,
        description: l10n.sectionFormsDescription,
        path: '/forms',
      ),
      _Section(
        icon: Icons.storefront_outlined,
        label: l10n.sectionBusinesses,
        description: l10n.sectionBusinessesDescription,
        path: '/businesses',
      ),
      _Section(
        icon: Icons.stadium_outlined,
        label: l10n.sectionFacilities,
        description: l10n.sectionFacilitiesDescription,
        path: '/facilities',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(municipality)),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSize.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    l10n.homeGreeting,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                if (activeRedAlerts.isNotEmpty) ...<Widget>[
                  _ActiveRedAlertBanner(alert: activeRedAlerts.first),
                  const SizedBox(height: AppSpacing.xl),
                ] else
                  const SizedBox(height: AppSpacing.xl),
                if (latestNewsWithImage != null && locale != null) ...<Widget>[
                  _LatestNewsHero(item: latestNewsWithImage, locale: locale),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Semantics(
                  header: true,
                  child: Text(
                    l10n.homeSectionsHeading,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _FeaturedSectionCard(section: featured),
                const SizedBox(height: AppSpacing.sm),
                // LayoutBuilder + a computed tile width, NOT a GridView with
                // a fixed aspect ratio: a cell height tuned for Spanish
                // overflows at 200% text scale in Valencian, which tends to
                // run 10-20% longer (A-12). Each tile's height stays
                // intrinsic — only the width is laid out as columns — so a
                // long translated label just grows the tile instead of
                // clipping.
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final int columns = constraints.maxWidth >= 520 ? 3 : 2;
                    const double spacing = AppSpacing.sm;
                    final double tileWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: <Widget>[
                        for (final _Section section in gridSections)
                          SizedBox(
                            width: tileWidth,
                            child: _SectionTile(section: section),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _FeaturedSectionCard(section: pharmacies, tinted: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The wide, high-emphasis row card: used once for the featured "report an
/// issue" shortcut and once for duty pharmacies at the bottom, matching the
/// two full-width CTAs in the Stitch home mockup.
class _FeaturedSectionCard extends StatelessWidget {
  const _FeaturedSectionCard({required this.section, this.tinted = false});

  final _Section section;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: tinted ? context.semantic.sunkenSurface : null,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgAll,
        side: tinted
            ? BorderSide(
                color: context.semantic.brandGraphic.withValues(alpha: 0.25),
              )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => context.go(section.path),
        child: Semantics(
          button: true,
          label: section.label,
          hint: section.description,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSize.comfortableTouchTarget,
            ),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: <Widget>[
                  AppIconBadge(
                    icon: section.icon,
                    size: AppIconBadgeSize.large,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          section.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          section.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const ExcludeSemantics(child: Icon(Icons.chevron_right)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact icon-over-label tile for the section grid — the equivalent of
/// Stitch's small bento tiles (icon, then label, no description).
class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => context.go(section.path),
        child: Semantics(
          button: true,
          label: section.label,
          hint: section.description,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSize.comfortableTouchTarget * 1.4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AppIconBadge(icon: section.icon),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    section.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cualquier alerta roja activa aparece aquí, arriba del todo — es la pieza
/// de mayor prioridad de Home. La especificidad ("esto es un incendio") la
/// aporta [phenomenonIcon]; el criterio de aparición sigue siendo severidad
/// roja, igual que el resto del sistema ("roja siempre fuerza notificación").
/// Nunca colores de marca aquí, solo los tokens de severidad de siempre.
class _ActiveRedAlertBanner extends StatelessWidget {
  const _ActiveRedAlertBanner({required this.alert});

  final MunicipalAlert alert;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SeverityColors palette = context.semantic.alertRed;
    return Semantics(
      liveRegion: true,
      button: true,
      label: '${l10n.homeActiveRedAlertBannerLabel}. ${alert.phenomenon}',
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xsAll,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          borderRadius: AppRadius.xsAll,
          onTap: () => context.go('/alerts'),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ExcludeSemantics(
                  child: Icon(
                    phenomenonIcon(alert.phenomenonType, alert.severity),
                    color: palette.heading,
                    size: AppSize.iconLg,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.homeActiveRedAlertBannerLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: palette.heading),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        alert.phenomenon,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: palette.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const ExcludeSemantics(child: Icon(Icons.chevron_right)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-bleed photo with a dark gradient scrim and the headline sitting on
/// top of it in white — the "Última hora" treatment from the Stitch
/// reference (Inicio screen). The only place in the resident app that puts
/// text directly over a photo, which is exactly why it stays limited to
/// this one high-visibility slot instead of becoming a general pattern.
class _LatestNewsHero extends StatelessWidget {
  const _LatestNewsHero({required this.item, required this.locale});

  final NewsItem item;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText title = item.title.resolve(locale);
    return Semantics(
      button: true,
      label: '${l10n.homeLatestNewsHeading}. ${title.text}',
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/news/${item.id}'),
            child: SizedBox(
              height: 260,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ExcludeSemantics(
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const <double>[0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: context.semantic.brandDecorative,
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Text(
                            l10n.homeLatestNewsHeading,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppPalette.neutral900,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          title.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppPalette.neutral0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
