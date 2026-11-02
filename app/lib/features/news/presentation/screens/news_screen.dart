import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/news_item.dart';
import '../viewmodels/news_view_model.dart';
import '../widgets/news_card.dart';
import '../widgets/news_card_skeleton.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<NewsUiState> news = ref.watch(newsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionNews)),
      drawer: const AppDrawer(),
      body: news.when(
        // First load, nothing cached yet: the skeleton mirrors the real
        // card layout instead of a plain spinner (§8.9).
        loading: () => const NewsListSkeleton(),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionNews,
          onRetry: () => ref.read(newsViewModelProvider.notifier).refresh(),
        ),
        data: (NewsUiState state) => _NewsContent(state: state),
      ),
    );
  }
}

class _NewsContent extends ConsumerWidget {
  const _NewsContent({required this.state});
  final NewsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLocale? locale = ref.watch(
      sessionViewModelProvider.select(
        (AsyncValue<SessionState> value) => value.value?.locale,
      ),
    );
    if (locale == null) return const NewsListSkeleton();

    if (state.failure != null && state.items.isEmpty && state.pinned.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionNews,
        onRetry: () => ref.read(newsViewModelProvider.notifier).refresh(),
      );
    }

    // The hero treatment only makes sense for the main, unfiltered feed —
    // on an archive or a category filter it would just be a confusing extra
    // step before the list the vecino actually asked to see.
    final bool showFeatured =
        state.pinned.isNotEmpty && !state.archived && state.category == null;
    final NewsItem? featured = showFeatured ? state.pinned.first : null;
    final List<NewsItem> rest = <NewsItem>[
      for (final NewsItem item in <NewsItem>[...state.pinned, ...state.items])
        if (item != featured) item,
    ];

    return RefreshIndicator(
      onRefresh: () => ref.read(newsViewModelProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          if (state.refreshing) ...<Widget>[
            Semantics(
              label: l10n.loadingNews,
              liveRegion: true,
              child: const LinearProgressIndicator(),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (featured != null) ...<Widget>[
            _FeaturedNewsCard(
              item: featured,
              locale: locale,
              onTap: () => context.push('/news/${featured.id}'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _NewsTabs(archived: state.archived),
          if (state.categories.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _CategoryFilter(
              categories: state.categories,
              selected: state.category,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          if (state.pinned.isEmpty && state.items.isEmpty)
            _EmptyNews(
              archived: state.archived,
              filtered: state.category != null,
            )
          else ...<Widget>[
            for (final NewsItem item in rest)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: NewsCard(
                  item: item,
                  locale: locale,
                  onTap: () => context.push('/news/${item.id}'),
                ),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionNews,
                  onRetry: () =>
                      ref.read(newsViewModelProvider.notifier).refresh(),
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
                        onPressed: () =>
                            ref.read(newsViewModelProvider.notifier).loadMore(),
                        child: Text(l10n.loadMore),
                      ),
              ),
          ],
        ],
      ),
    );
  }
}

/// The one big story of the moment, styled to stand apart from the plain
/// list below it — a large photo, the category called out above the
/// headline, an excerpt, and an explicit "read more" affordance. Reuses
/// [NewsCard]'s own pinned marker convention but at hero scale, matching the
/// featured-article treatment from the Stitch reference (Noticias screen).
class _FeaturedNewsCard extends StatelessWidget {
  const _FeaturedNewsCard({
    required this.item,
    required this.locale,
    required this.onTap,
  });

  final NewsItem item;
  final AppLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText title = item.title.resolve(locale);
    final ResolvedLocalizedText body = item.body.resolve(locale);
    final String category = localizedCategory(l10n, item.category);
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(item.publishedAt.toLocal());

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: l10n.newsSemanticCard(
        title.text,
        category,
        date,
        l10n.newsAttachmentsCount(item.attachments.length),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: AppElevation.level2,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (item.imageUrl != null)
                ExcludeSemantics(
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      children: <Widget>[
                        Text(
                          category.toUpperCase(),
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: context.semantic.brandGraphic,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          '·',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          date,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title.text,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      body.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.semantic.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xxs,
                      children: <Widget>[
                        Text(
                          l10n.newsReadFullArticle,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: context.semantic.brandGraphic),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: AppSize.iconSm,
                          color: context.semantic.brandGraphic,
                        ),
                      ],
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

/// Actualidad / Histórico switch, built from `Wrap` + `FilterChip` instead of
/// `SegmentedButton` inside a horizontal scroller: at 200% text scale in
/// Valencian a `SegmentedButton` can overflow its row, and a scroller would
/// hide half of it off-screen. A `Wrap` just drops to a second line — nothing
/// is ever clipped or hidden (§8.6, A-13).
class _NewsTabs extends ConsumerWidget {
  const _NewsTabs({required this.archived});
  final bool archived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        _TabChip(
          label: l10n.newsTabCurrent,
          icon: Icons.newspaper_outlined,
          selected: !archived,
          onTap: () =>
              ref.read(newsViewModelProvider.notifier).setArchived(false),
        ),
        _TabChip(
          label: l10n.newsTabArchive,
          icon: Icons.archive_outlined,
          selected: archived,
          onTap: () =>
              ref.read(newsViewModelProvider.notifier).setArchived(true),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The chip's own semantics are replaced rather than merged with ours:
    // otherwise a screen reader announces both "Actualidad, chip" and our
    // "selected" flag as two separate, slightly redundant nodes (A-28).
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: FilterChip(
        avatar: Icon(selected ? Icons.check_circle_outline : icon),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
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
              ref.read(newsViewModelProvider.notifier).setCategory(null),
        ),
        for (final String category in categories)
          _CategoryChip(
            label: localizedCategory(l10n, category),
            semanticLabel: l10n.newsFilterSemantic(
              localizedCategory(l10n, category),
            ),
            selected: selected == category,
            onTap: () =>
                ref.read(newsViewModelProvider.notifier).setCategory(category),
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

class _EmptyNews extends ConsumerWidget {
  const _EmptyNews({required this.archived, required this.filtered});
  final bool archived;
  final bool filtered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = filtered
        ? l10n.emptyByFilterTitle
        : archived
        ? l10n.emptyNewsArchiveTitle
        : l10n.emptyNewsTitle;
    final String body = filtered
        ? l10n.emptyByFilterBody
        : archived
        ? l10n.emptyNewsArchiveBody
        : l10n.emptyNewsBody;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.newspaper_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(body, textAlign: TextAlign.center),
          if (filtered) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(newsViewModelProvider.notifier).setCategory(null),
              child: Text(l10n.emptyClearFilters),
            ),
          ],
        ],
      ),
    );
  }
}
