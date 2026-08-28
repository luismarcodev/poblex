import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/category_label.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/business.dart';
import '../viewmodels/businesses_view_model.dart';

class BusinessesScreen extends ConsumerWidget {
  const BusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<BusinessesUiState> businesses = ref.watch(
      businessesViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionBusinesses)),
      drawer: const AppDrawer(),
      body: businesses.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
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
          sectionName: l10n.sectionBusinesses,
          onRetry: () =>
              ref.read(businessesViewModelProvider.notifier).refresh(),
        ),
        data: (BusinessesUiState state) => _BusinessesContent(state: state),
      ),
    );
  }
}

class _BusinessesContent extends ConsumerWidget {
  const _BusinessesContent({required this.state});
  final BusinessesUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifier = ref.read(businessesViewModelProvider.notifier);

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionBusinesses,
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
          AppSpacing.xxl,
        ),
        children: <Widget>[
          if (state.categories.isNotEmpty) ...<Widget>[
            _CategoryFilter(
              categories: state.categories,
              selected: state.category,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (state.isEmpty)
            _EmptyBusinesses(filtered: state.category != null)
          else ...<Widget>[
            for (final MunicipalBusiness business in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _BusinessTile(business: business),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionBusinesses,
                  onRetry: notifier.refresh,
                ),
              ),
            if (state.nextCursor != null && state.failure == null)
              Center(
                child: state.loadingMore
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: CircularProgressIndicator(),
                      )
                    : FilledButton.tonal(
                        onPressed: notifier.loadMore,
                        child: Text(l10n.loadMore),
                      ),
              ),
          ],
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
              ref.read(businessesViewModelProvider.notifier).setCategory(null),
        ),
        for (final String category in categories)
          _CategoryChip(
            label: prettifyCategorySlug(category),
            semanticLabel: l10n.newsFilterSemantic(
              prettifyCategorySlug(category),
            ),
            selected: selected == category,
            onTap: () => ref
                .read(businessesViewModelProvider.notifier)
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

class _BusinessTile extends StatelessWidget {
  const _BusinessTile({required this.business});
  final MunicipalBusiness business;

  @override
  Widget build(BuildContext context) {
    final String categoryLabel = prettifyCategorySlug(business.category);

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '${business.name}. $categoryLabel',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/businesses/${business.id}'),
          child: Row(
            children: <Widget>[
              if (business.photoUrls.isNotEmpty)
                ExcludeSemantics(
                  child: Image.network(
                    business.photoUrls.first,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _BusinessPlaceholder(),
                  ),
                )
              else
                const _BusinessPlaceholder(),
              Expanded(
                child: Padding(
                  padding: AppSpacing.cardPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        business.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Chip(label: Text(categoryLabel)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BusinessPlaceholder extends StatelessWidget {
  const _BusinessPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: ColoredBox(
        color: context.colors.surfaceContainerHighest,
        child: const Center(
          child: AppIconBadge(
            icon: Icons.storefront_outlined,
            size: AppIconBadgeSize.medium,
          ),
        ),
      ),
    );
  }
}

class _EmptyBusinesses extends ConsumerWidget {
  const _EmptyBusinesses({required this.filtered});
  final bool filtered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = filtered
        ? l10n.emptyByFilterTitle
        : l10n.emptyBusinessesTitle;
    final String body = filtered
        ? l10n.emptyByFilterBody
        : l10n.emptyBusinessesBody;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.storefront_outlined,
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
                  .read(businessesViewModelProvider.notifier)
                  .setCategory(null),
              child: Text(l10n.emptyClearFilters),
            ),
          ],
        ],
      ),
    );
  }
}
