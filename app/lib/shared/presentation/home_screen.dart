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
    required this.imageAsset,
    required this.label,
    required this.description,
    required this.path,
  });

  /// Bundled, generic category artwork (CC0/public domain — see
  /// docs/branding.md "Iconografía de categoría"), never municipality
  /// content. Replaces the old [IconData]: the home grid is photo-led now,
  /// not an icon catalogue.
  final String imageAsset;
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

    // Un único grid, mismo trato visual para todas las secciones — nada de
    // tarjeta "destacada" aparte. El único elemento no-grid que puede
    // aparecer o no es el banner de alerta roja de arriba, que ya depende
    // de lo que el gestor publique desde el backoffice.
    final List<_Section> sections = <_Section>[
      _Section(
        imageAsset: 'assets/images/home_sections/incidents.jpg',
        label: l10n.sectionIncidents,
        description: l10n.sectionIncidentsDescription,
        path: '/incidents',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/news.jpg',
        label: l10n.sectionNews,
        description: l10n.sectionNewsDescription,
        path: '/news',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/alerts.jpg',
        label: l10n.sectionAlerts,
        description: l10n.sectionAlertsDescription,
        path: '/alerts',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/events.jpg',
        label: l10n.sectionEvents,
        description: l10n.sectionEventsDescription,
        path: '/events',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/surveys.jpg',
        label: l10n.sectionSurveys,
        description: l10n.sectionSurveysDescription,
        path: '/surveys',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/forms.jpg',
        label: l10n.sectionForms,
        description: l10n.sectionFormsDescription,
        path: '/forms',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/businesses.jpg',
        label: l10n.sectionBusinesses,
        description: l10n.sectionBusinessesDescription,
        path: '/businesses',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/facilities.jpg',
        label: l10n.sectionFacilities,
        description: l10n.sectionFacilitiesDescription,
        path: '/facilities',
      ),
      _Section(
        imageAsset: 'assets/images/home_sections/pharmacies.jpg',
        label: l10n.sectionPharmacies,
        description: l10n.sectionPharmaciesDescription,
        path: '/pharmacies',
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
                if (activeRedAlerts.isNotEmpty) ...<Widget>[
                  _ActiveRedAlertBanner(alert: activeRedAlerts.first),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (latestNewsWithImage != null && locale != null) ...<Widget>[
                  _LatestNewsHero(item: latestNewsWithImage, locale: locale),
                  const SizedBox(height: AppSpacing.xl),
                ],
                // LayoutBuilder + a computed tile width, NOT a GridView con
                // aspect ratio fijo: la altura de cada celda queda
                // intrínseca — solo el ancho se reparte en columnas — para
                // que una etiqueta larga en valenciano al 200% (A-12) crezca
                // la tarjeta en vez de recortarse. Dos columnas siempre,
                // nunca tres: tarjetas grandes y visuales es el objetivo,
                // no encajar más secciones por fila.
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    const int columns = 2;
                    const double spacing = AppSpacing.sm;
                    final double tileWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: <Widget>[
                        for (final _Section section in sections)
                          SizedBox(
                            width: tileWidth,
                            child: _SectionTile(section: section),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Caption-bar background for every image tile below. Deliberately the same
/// fixed token in light AND dark theme — [AppPalette.darkBackground] is
/// already verified at 16.59:1 against white/[AppPalette.darkOnSurface]
/// (see docs/design-system.md §2.5), so white label text over it clears AA
/// by a wide margin regardless of what the photo above it looks like. A
/// gradient over the raw photo alone can't give that guarantee for
/// arbitrary stock images, so the label always sits on this solid strip,
/// never directly on pixels we don't control.
const Color _imageCaptionBar = AppPalette.darkBackground;
const Color _imageCaptionText = AppPalette.darkOnSurface;

/// Image-led shortcut: a representative photo with the label captioned
/// below it on a solid bar, replacing the old text-only row. The photo
/// identifies the category at a glance; the visible caption and the
/// `Semantics` label/hint still carry the full meaning, same as before —
/// an image is never the only indicator of what a tile does (A-39 extends
/// the "never an icon alone" rule to photos).
class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      child: InkWell(
        onTap: () => context.go(section.path),
        child: Semantics(
          button: true,
          label: section.label,
          hint: section.description,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSize.comfortableTouchTarget * 2.6,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      ExcludeSemantics(
                        child: Image.asset(
                          section.imageAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Fades the photo into the caption bar's own colour so
                      // the seam between image and caption reads as one
                      // continuous surface, not two stacked rectangles.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Colors.transparent,
                              _imageCaptionBar,
                            ],
                            stops: <double>[0.72, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ColoredBox(
                  color: _imageCaptionBar,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      section.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _imageCaptionText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
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
      label:
          '${l10n.alertSeverityLabel(alert.severity.slug)}. '
          '${l10n.homeActiveRedAlertBannerLabel}. ${alert.phenomenon}',
      excludeSemantics: true,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xsAll,
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: AppRadius.xsAll,
          onTap: () => context.go('/alerts'),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: toDesignSeverity(alert.severity).barWidth,
                  color: palette.bar,
                ),
                Expanded(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SeverityBadge(
                          label: l10n.alertSeverityLabel(alert.severity.slug),
                          severity: alert.severity,
                          palette: palette,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.homeActiveRedAlertBannerLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: palette.heading),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          alert.phenomenon,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: palette.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Featured news uses the municipality's own photography as the visual anchor.
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
      excludeSemantics: true,
      label: '${l10n.homeLatestNewsHeading}. ${title.text}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.go('/news/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 240,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ExcludeSemantics(
                      child: CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => ColoredBox(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Color(0xCC111820),
                          ],
                          stops: <double>[0.34, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing.lg,
                      bottom: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            title.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
