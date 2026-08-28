import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_event.dart';
import '../viewmodels/events_view_model.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final events = ref.watch(
      eventsViewModelProvider.select(
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
                  ref.read(eventsViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      includePast: events.valueOrNull?.includePast ?? false,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...events.when(
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
                                  _EventCard(event: state.items[index]),
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
  const _Header({required this.includePast});

  final bool includePast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        final title = Text(l10n.eventsTitle, style: context.text.headlineLarge);
        final filter = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: includePast,
              onChanged: (value) => ref
                  .read(eventsViewModelProvider.notifier)
                  .setIncludePast(value),
            ),
            Flexible(child: Text(l10n.includePastEvents)),
          ],
        );
        final add = FilledButton.icon(
          onPressed: () => context.go('/eventos/nuevo'),
          icon: const Icon(Icons.add),
          label: Text(l10n.newEvent),
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

  final EventsUiState state;

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
                  ref.read(eventsViewModelProvider.notifier).loadMore(),
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

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event});

  final ManagedEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(
      eventsViewModelProvider.select(
        (events) => events.valueOrNull?.busyIds.contains(event.id) ?? false,
      ),
    );
    final locale = Localizations.localeOf(context).languageCode;
    final prefersValencian = locale == 'ca';
    final title = _localizedValue(event.title, prefersValencian);
    final description = _localizedValue(event.description, prefersValencian);
    final dateFormat = DateFormat.yMMMd(locale).add_Hm();
    final status = event.statusAt(DateTime.now());
    final statusLabel = switch (status) {
      ManagedEventStatus.upcoming => l10n.eventUpcomingStatus,
      ManagedEventStatus.ongoing => l10n.eventOngoingStatus,
      ManagedEventStatus.past => l10n.eventPastStatus,
    };
    final statusIcon = switch (status) {
      ManagedEventStatus.upcoming => Icons.event_available_outlined,
      ManagedEventStatus.ongoing => Icons.play_circle_outline,
      ManagedEventStatus.past => Icons.event_busy_outlined,
    };

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
                  avatar: Icon(statusIcon, size: 20),
                  label: Text(statusLabel),
                ),
                Chip(label: Text(event.category)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            _MetadataLine(
              icon: Icons.schedule,
              text: l10n.eventStartsOn(
                dateFormat.format(event.startAt.toLocal()),
              ),
            ),
            if (event.endAt case final endAt?) ...[
              const SizedBox(height: AppSpacing.xs),
              _MetadataLine(
                icon: Icons.event_available,
                text: l10n.eventEndsOn(dateFormat.format(endAt.toLocal())),
              ),
            ],
            if (event.locationName case final location?) ...[
              const SizedBox(height: AppSpacing.xs),
              _MetadataLine(icon: Icons.place_outlined, text: location),
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
                        '/eventos/editar/${event.id}',
                        extra: event,
                      );
                      if (context.mounted) {
                        ref.read(eventsViewModelProvider.notifier).refresh();
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.edit),
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
        title: Text(l10n.deleteEventTitle),
        content: Text(l10n.deleteEventBody),
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
      ref.read(eventsViewModelProvider.notifier).delete(event),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(child: Icon(icon, size: 24)),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text, style: context.text.bodyMedium)),
    ],
  );
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
            icon: Icons.event_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noEventsTitle, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.noEventsBody, textAlign: TextAlign.center),
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
                    ref.read(eventsViewModelProvider.notifier).refresh(),
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

String _localizedValue(EventLocalizedText text, bool prefersValencian) {
  final valencian = text.va?.trim();
  if (prefersValencian && valencian != null && valencian.isNotEmpty) {
    return valencian;
  }
  if (text.es.trim().isNotEmpty) return text.es;
  return valencian ?? '';
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
