import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/category_label.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/facility.dart';
import '../viewmodels/facilities_view_model.dart';

class FacilitiesScreen extends ConsumerWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<FacilitiesUiState> facilities = ref.watch(
      facilitiesViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionFacilities)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/reservations'),
        icon: const Icon(Icons.event_available_outlined),
        label: Text(l10n.myReservationsTitle),
      ),
      body: facilities.when(
        loading: () => Semantics(
          label: l10n.loading,
          liveRegion: true,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            itemCount: 3,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) =>
                const AppSkeleton(height: 96),
          ),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionFacilities,
          onRetry: () =>
              ref.read(facilitiesViewModelProvider.notifier).refresh(),
        ),
        data: (FacilitiesUiState state) => _FacilitiesContent(state: state),
      ),
    );
  }
}

class _FacilitiesContent extends ConsumerWidget {
  const _FacilitiesContent({required this.state});
  final FacilitiesUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifier = ref.read(facilitiesViewModelProvider.notifier);

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionFacilities,
        onRetry: notifier.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.giant,
        ),
        children: <Widget>[
          if (state.availableCategories.length > 1) ...<Widget>[
            _CategoryFilter(
              categories: state.availableCategories,
              selected: state.category,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (state.isEmpty)
            _EmptyFacilities(filtered: state.category != null)
          else
            for (final Facility facility in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _FacilityTile(facility: facility),
              ),
          if (state.failure != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: InlineFailureView(
                failure: state.failure!,
                sectionName: l10n.sectionFacilities,
                onRetry: notifier.refresh,
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  const _CategoryFilter({required this.categories, required this.selected});

  final List<String> categories;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        _CategoryChip(
          label: l10n.newsFilterAll,
          semanticLabel: l10n.newsFilterAll,
          selected: selected == null,
          onTap: () =>
              ref.read(facilitiesViewModelProvider.notifier).setCategory(null),
        ),
        for (final String category in categories)
          _CategoryChip(
            label: prettifyCategorySlug(category),
            semanticLabel: l10n.newsFilterSemantic(
              prettifyCategorySlug(category),
            ),
            selected: selected == category,
            onTap: () => ref
                .read(facilitiesViewModelProvider.notifier)
                .setCategory(category),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _FacilityTile extends ConsumerWidget {
  const _FacilityTile({required this.facility});
  final Facility facility;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String categoryLabel = prettifyCategorySlug(facility.category);
    final AppLocale locale =
        ref.watch(sessionViewModelProvider).valueOrNull?.locale ?? AppLocale.es;
    final String name = facility.name.resolve(locale).text;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$name. $categoryLabel',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/facilities/${facility.id}'),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: <Widget>[
                AppIconBadge(
                  icon: _categoryIcon(facility.category),
                  size: AppIconBadgeSize.medium,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: <Widget>[
                          Chip(label: Text(categoryLabel)),
                          if (facility.feeNote != null)
                            Chip(
                              avatar: const Icon(
                                Icons.payments_outlined,
                                size: 16,
                              ),
                              label: Text(l10n.facilityFeeNoteHeading),
                            ),
                        ],
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

/// Iconos sin equivalente exacto en Material para pádel/frontón: se reutiliza
/// el más cercano (tenis para pádel, "sports" genérico para el resto) — el
/// nombre real de la instalación siempre acompaña al icono, así que nunca es
/// la única pista de qué es.
IconData _categoryIcon(String category) {
  final String normalized = category.toLowerCase();
  if (normalized.contains('padel') || normalized.contains('pàdel')) {
    return Icons.sports_tennis;
  }
  if (normalized.contains('tenis') || normalized.contains('tennis')) {
    return Icons.sports_tennis;
  }
  if (normalized.contains('futbol') || normalized.contains('fútbol')) {
    return Icons.sports_soccer;
  }
  if (normalized.contains('piscina')) return Icons.pool;
  if (normalized.contains('gimnas')) return Icons.fitness_center;
  if (normalized.contains('barbacoa')) return Icons.outdoor_grill;
  if (normalized.contains('sala')) return Icons.meeting_room_outlined;
  return Icons.stadium_outlined;
}

class _EmptyFacilities extends ConsumerWidget {
  const _EmptyFacilities({required this.filtered});
  final bool filtered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = filtered
        ? l10n.emptyByFilterTitle
        : l10n.emptyFacilitiesTitle;
    final String body = filtered
        ? l10n.emptyByFilterBody
        : l10n.emptyFacilitiesBody;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.stadium_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(body, textAlign: TextAlign.center),
          if (filtered) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(
              onPressed: () => ref
                  .read(facilitiesViewModelProvider.notifier)
                  .setCategory(null),
              child: Text(l10n.emptyClearFilters),
            ),
          ],
        ],
      ),
    );
  }
}
