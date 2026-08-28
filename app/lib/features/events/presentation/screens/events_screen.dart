import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/event.dart';
import '../viewmodels/events_view_model.dart';
import '../widgets/event_card.dart';
import '../widgets/reminder_picker.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<EventsUiState> events = ref.watch(eventsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionEvents)),
      drawer: const AppDrawer(),
      body: events.when(
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
                const AppSkeleton(height: 132),
          ),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionEvents,
          onRetry: () => ref.read(eventsViewModelProvider.notifier).refresh(),
        ),
        data: (EventsUiState state) => _EventsContent(state: state),
      ),
    );
  }
}

class _EventsContent extends ConsumerWidget {
  const _EventsContent({required this.state});
  final EventsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionViewModelProvider).value?.locale;
    if (locale == null) return const SizedBox.shrink();

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionEvents,
        onRetry: () => ref.read(eventsViewModelProvider.notifier).refresh(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(eventsViewModelProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          if (state.isEmpty)
            const _EmptyEvents()
          else ...<Widget>[
            for (final MunicipalEvent event in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: EventCard(
                  event: event,
                  locale: locale,
                  hasReminder: state.remindedEventIds.contains(event.id),
                  onTap: () => context.push('/events/${event.id}'),
                  onToggleReminder: () => _toggleReminder(context, ref, event),
                ),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionEvents,
                  onRetry: () =>
                      ref.read(eventsViewModelProvider.notifier).refresh(),
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
                        onPressed: () => ref
                            .read(eventsViewModelProvider.notifier)
                            .loadMore(),
                        child: Text(l10n.loadMore),
                      ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleReminder(
    BuildContext context,
    WidgetRef ref,
    MunicipalEvent event,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifier = ref.read(eventsViewModelProvider.notifier);
    final bool hasReminder =
        (ref.read(eventsViewModelProvider).value?.remindedEventIds ??
                const <String>{})
            .contains(event.id);

    if (hasReminder) {
      final result = await notifier.cancelReminder(event.id);
      if (!context.mounted) return;
      if (result.isSuccess) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.eventReminderCancelled)));
      }
      return;
    }

    final DateTime? remindAt = await pickEventReminderTime(
      context,
      eventStart: event.startAt,
    );
    if (remindAt == null || !context.mounted) return;
    final result = await notifier.setReminder(event.id, remindAt);
    if (!context.mounted) return;
    if (result.isSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.eventReminderConfirmed)));
    }
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.event_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyEventsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.emptyEventsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
