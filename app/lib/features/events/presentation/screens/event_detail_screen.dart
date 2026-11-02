import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/category_label.dart';
import '../../domain/entities/event.dart';
import '../viewmodels/event_detail_view_model.dart';
import '../widgets/reminder_picker.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<EventDetailUiState> detail = ref.watch(
      eventDetailViewModelProvider(eventId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.eventDetailTitle)),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionEvents,
          onRetry: () =>
              ref.read(eventDetailViewModelProvider(eventId).notifier).retry(),
        ),
        data: (EventDetailUiState value) {
          if (value.failure != null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionEvents,
              onRetry: () => ref
                  .read(eventDetailViewModelProvider(eventId).notifier)
                  .retry(),
            );
          }
          return _EventDetail(
            eventId: eventId,
            event: value.event!,
            hasReminder: value.hasReminder,
          );
        },
      ),
    );
  }
}

class _EventDetail extends ConsumerWidget {
  const _EventDetail({
    required this.eventId,
    required this.event,
    required this.hasReminder,
  });

  final String eventId;
  final MunicipalEvent event;
  final bool hasReminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale =
        ref.watch(sessionViewModelProvider).valueOrNull?.locale ?? AppLocale.es;
    final ResolvedLocalizedText title = event.title.resolve(locale);
    final ResolvedLocalizedText description = event.description.resolve(locale);
    final String languageTag = Localizations.localeOf(context).toLanguageTag();
    final String dateAndTime =
        '${DateFormat.yMMMMEEEEd(languageTag).format(event.startAt.toLocal())} · '
        '${DateFormat.Hm(languageTag).format(event.startAt.toLocal())}';

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Chip(label: Text(prettifyCategorySlug(event.category))),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title.text,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(icon: Icons.schedule_outlined, text: dateAndTime),
                if (event.locationName != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  _InfoRow(
                    icon: Icons.place_outlined,
                    text: event.locationName!,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  description.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: hasReminder
                      ? OutlinedButton.icon(
                          onPressed: () => _cancelReminder(context, ref),
                          icon: const Icon(Icons.notifications_active),
                          label: Text(l10n.eventReminderActive),
                        )
                      : FilledButton.icon(
                          onPressed: event.isPastAt(DateTime.now())
                              ? null
                              : () => _setReminder(context, ref),
                          icon: const Icon(Icons.notifications_none_outlined),
                          label: Text(l10n.eventReminderSet),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _setReminder(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime? remindAt = await pickEventReminderTime(
      context,
      eventStart: event.startAt,
    );
    if (remindAt == null || !context.mounted) return;
    final result = await ref
        .read(eventDetailViewModelProvider(eventId).notifier)
        .setReminder(remindAt);
    if (!context.mounted || !result.isSuccess) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.eventReminderConfirmed)));
  }

  Future<void> _cancelReminder(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final result = await ref
        .read(eventDetailViewModelProvider(eventId).notifier)
        .cancelReminder();
    if (!context.mounted || !result.isSuccess) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.eventReminderCancelled)));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExcludeSemantics(child: Icon(icon, size: AppSize.iconSm)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(text)),
      ],
    );
  }
}
