import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/news_item.dart';
import '../viewmodels/news_view_model.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final news = ref.watch(
      newsViewModelProvider.select(
        (value) => value.whenData(
          (state) => state.copyWith(busyIds: const <String>{}),
        ),
      ),
    );

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSize.maxWorkspaceWidth,
          ),
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(newsViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      includeArchived:
                          news.valueOrNull?.includeArchived ?? false,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...news.when(
                    loading: () => [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Semantics(
                          liveRegion: true,
                          label: l10n.loading,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
                    error: (error, _) => [
                      SliverToBoxAdapter(child: _ErrorState(error: error)),
                    ],
                    data: (state) => state.items.isEmpty
                        ? const [SliverToBoxAdapter(child: _EmptyState())]
                        : [
                            SliverList.builder(
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return _NewsCard(item: item);
                              },
                            ),
                            if (state.nextCursor != null)
                              SliverToBoxAdapter(
                                child: _LoadMoreButton(state: state),
                              ),
                          ],
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

class _Header extends ConsumerWidget {
  const _Header({required this.includeArchived});
  final bool includeArchived;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final title = Text(l10n.newsTitle, style: context.text.headlineLarge);
        final filter = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: includeArchived,
              onChanged: (value) => ref
                  .read(newsViewModelProvider.notifier)
                  .setIncludeArchived(value),
            ),
            Flexible(child: Text(l10n.includeArchived)),
          ],
        );
        final add = FilledButton.icon(
          onPressed: () => context.go('/noticias/nueva'),
          icon: const Icon(Icons.add),
          label: Text(l10n.newNews),
        );
        final socialConnections = IconButton(
          onPressed: () => context.go('/noticias/conexiones'),
          icon: const Icon(Icons.share_outlined),
          tooltip: l10n.socialConnectionsTooltip,
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: title),
                  socialConnections,
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              filter,
              const SizedBox(height: AppSpacing.sm),
              add,
            ],
          );
        }
        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            title,
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [filter, socialConnections, add],
            ),
          ],
        );
      },
    );
  }
}

class _LoadMoreButton extends ConsumerWidget {
  const _LoadMoreButton({required this.state});
  final NewsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: state.isLoadingMore
              ? null
              : () => _runMutation(
                  context,
                  ref.read(newsViewModelProvider.notifier).loadMore(),
                ),
          icon: state.isLoadingMore
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Icon(Icons.expand_more),
          label: Text(l10n.loadMore),
        ),
      ),
    );
  }
}

class _NewsCard extends ConsumerWidget {
  const _NewsCard({required this.item});
  final NewsItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(
      newsViewModelProvider.select(
        (news) => news.valueOrNull?.busyIds.contains(item.id) ?? false,
      ),
    );
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat.yMMMd(locale).format(item.publishedAt.toLocal());
    final prefersValencian = locale == 'ca';
    final title = _localizedValue(item.title, prefersValencian);
    final body = _localizedValue(item.body, prefersValencian);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _StatusChip(
                  label: item.archived ? l10n.archivedLabel : l10n.activeLabel,
                  icon: item.archived
                      ? Icons.archive_outlined
                      : Icons.check_circle_outline,
                ),
                if (item.pinned)
                  _StatusChip(
                    label: l10n.pinnedStatusLabel,
                    icon: Icons.push_pin_outlined,
                  ),
                Chip(label: Text(item.category)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.publishedOn(date),
              style: context.text.bodySmall?.copyWith(
                color: context.semantic.textMuted,
              ),
            ),
            const Divider(height: AppSpacing.xl),
            if (busy)
              Semantics(
                liveRegion: true,
                label: l10n.loading,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await context.push(
                        '/noticias/editar/${item.id}',
                        extra: item,
                      );
                      if (context.mounted) {
                        ref.read(newsViewModelProvider.notifier).refresh();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.edit),
                  ),
                  TextButton.icon(
                    onPressed: () => _runMutation(
                      context,
                      ref.read(newsViewModelProvider.notifier).setPinned(item),
                    ),
                    icon: Icon(
                      item.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    ),
                    label: Text(item.pinned ? l10n.unpin : l10n.pin),
                  ),
                  TextButton.icon(
                    onPressed: () => _runMutation(
                      context,
                      ref
                          .read(newsViewModelProvider.notifier)
                          .setArchived(item),
                    ),
                    icon: Icon(
                      item.archived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                    ),
                    label: Text(item.archived ? l10n.restore : l10n.archive),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTitle),
        content: Text(l10n.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _runMutation(
      context,
      ref.read(newsViewModelProvider.notifier).delete(item),
    );
  }
}

String _localizedValue(LocalizedText text, bool prefersValencian) {
  final valencian = text.va?.trim();
  if (prefersValencian && valencian != null && valencian.isNotEmpty) {
    return valencian;
  }
  if (text.es.trim().isNotEmpty) return text.es;
  return valencian ?? '';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 20), label: Text(label));
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: [
          const AppIconBadge(
            icon: Icons.newspaper_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noNewsTitle, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.noNewsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.error});
  final Object error;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56),
              const SizedBox(height: AppSpacing.md),
              Text(
                error is NetworkFailure ? l10n.networkError : l10n.genericError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(newsViewModelProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _runMutation(
  BuildContext context,
  Future<AppFailure?> operation,
) async {
  final failure = await operation;
  if (failure == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        failure is NetworkFailure ? l10n.networkError : l10n.genericError,
      ),
    ),
  );
}
