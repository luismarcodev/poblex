import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_business.dart';
import '../viewmodels/businesses_view_model.dart';

class BusinessesScreen extends ConsumerWidget {
  const BusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final businesses = ref.watch(
      businessesViewModelProvider.select(
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
                  ref.read(businessesViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      includeInactive:
                          businesses.valueOrNull?.includeInactive ?? false,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...businesses.when(
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
                              itemBuilder: (context, index) =>
                                  _BusinessCard(business: state.items[index]),
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
  const _Header({required this.includeInactive});
  final bool includeInactive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final title = Text(
          l10n.businessesTitle,
          style: context.text.headlineLarge,
        );
        final filter = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: includeInactive,
              onChanged: (value) => ref
                  .read(businessesViewModelProvider.notifier)
                  .setIncludeInactive(value),
            ),
            Flexible(child: Text(l10n.includeInactiveBusinesses)),
          ],
        );
        final add = FilledButton.icon(
          onPressed: () => context.go('/comercios/nuevo'),
          icon: const Icon(Icons.add),
          label: Text(l10n.newBusiness),
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: AppSpacing.sm),
              filter,
              const SizedBox(height: AppSpacing.sm),
              add,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: title),
            filter,
            const SizedBox(width: AppSpacing.md),
            add,
          ],
        );
      },
    );
  }
}

class _LoadMoreButton extends ConsumerWidget {
  const _LoadMoreButton({required this.state});
  final BusinessesUiState state;

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
                  ref.read(businessesViewModelProvider.notifier).loadMore(),
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

class _BusinessCard extends ConsumerWidget {
  const _BusinessCard({required this.business});
  final ManagedBusiness business;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(
      businessesViewModelProvider.select(
        (value) => value.valueOrNull?.busyIds.contains(business.id) ?? false,
      ),
    );

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
                Chip(
                  avatar: Icon(
                    business.active
                        ? Icons.check_circle_outline
                        : Icons.pause_circle_outline,
                    size: 20,
                  ),
                  label: Text(
                    business.active
                        ? l10n.activeLabel
                        : l10n.businessInactiveLabel,
                  ),
                ),
                Chip(label: Text(business.category)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(business.name, style: context.text.titleLarge),
            if (business.address != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                business.address!,
                style: context.text.bodyMedium?.copyWith(
                  color: context.semantic.textMuted,
                ),
              ),
            ],
            if (business.photos.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${business.photos.length}',
                style: context.text.bodySmall?.copyWith(
                  color: context.semantic.textMuted,
                ),
              ),
            ],
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
                        '/comercios/editar/${business.id}',
                        extra: business,
                      );
                      if (context.mounted) {
                        ref
                            .read(businessesViewModelProvider.notifier)
                            .refresh();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.edit),
                  ),
                  TextButton.icon(
                    onPressed: () => _runMutation(
                      context,
                      ref
                          .read(businessesViewModelProvider.notifier)
                          .setActive(business),
                    ),
                    icon: Icon(
                      business.active
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                    ),
                    label: Text(
                      business.active ? l10n.deactivate : l10n.activate,
                    ),
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
        title: Text(l10n.deleteBusinessTitle),
        content: Text(l10n.deleteBusinessBody),
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
      ref.read(businessesViewModelProvider.notifier).delete(business),
    );
  }
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
            icon: Icons.storefront_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noBusinessesTitle, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.noBusinessesBody, textAlign: TextAlign.center),
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
                    ref.read(businessesViewModelProvider.notifier).refresh(),
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
