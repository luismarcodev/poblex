import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/facility.dart';
import '../viewmodels/my_reservations_view_model.dart';

class MyReservationsScreen extends ConsumerWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<MyReservationsUiState> reservations = ref.watch(
      myReservationsViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myReservationsTitle)),
      drawer: const AppDrawer(),
      body: reservations.when(
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
          sectionName: l10n.myReservationsTitle,
          onRetry: () =>
              ref.read(myReservationsViewModelProvider.notifier).refresh(),
        ),
        data: (MyReservationsUiState state) =>
            _MyReservationsContent(state: state),
      ),
    );
  }
}

class _MyReservationsContent extends ConsumerWidget {
  const _MyReservationsContent({required this.state});
  final MyReservationsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifier = ref.read(myReservationsViewModelProvider.notifier);
    final AppLocale locale =
        ref.watch(sessionViewModelProvider).valueOrNull?.locale ?? AppLocale.es;
    final String languageTag = Localizations.localeOf(context).toLanguageTag();

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.myReservationsTitle,
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
          if (state.isEmpty)
            _EmptyReservations(l10n: l10n)
          else ...<Widget>[
            for (final Reservation reservation in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ReservationTile(
                  reservation: reservation,
                  facility: state.facilitiesById[reservation.facilityId],
                  cancelling: state.cancellingId == reservation.id,
                  locale: locale,
                  languageTag: languageTag,
                  onCancel: () => _confirmCancel(
                    context,
                    notifier,
                    reservation,
                    state.facilitiesById[reservation.facilityId],
                    locale,
                    languageTag,
                    l10n,
                  ),
                ),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.myReservationsTitle,
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

  Future<void> _confirmCancel(
    BuildContext context,
    MyReservationsViewModel notifier,
    Reservation reservation,
    Facility? facility,
    AppLocale locale,
    String languageTag,
    AppLocalizations l10n,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.reservationCancelConfirmTitle),
        content: Text(l10n.reservationCancelConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.reservationCancelConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await notifier.cancel(reservation.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Semantics(
                liveRegion: true,
                child: Text(l10n.reservationCancelledSnackbar),
              ),
            ),
          );
      }
    }
  }
}

class _ReservationTile extends StatelessWidget {
  const _ReservationTile({
    required this.reservation,
    required this.facility,
    required this.cancelling,
    required this.locale,
    required this.languageTag,
    required this.onCancel,
  });

  final Reservation reservation;
  final Facility? facility;
  final bool cancelling;
  final AppLocale locale;
  final String languageTag;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String name =
        facility?.name.resolve(locale).text ?? l10n.facilityDetailTitle;
    final String dateLabel = DateFormat.yMMMMEEEEd(
      languageTag,
    ).format(reservation.slotStart.toLocal());
    final String startLabel = DateFormat.Hm(
      languageTag,
    ).format(reservation.slotStart.toLocal());
    final String endLabel = DateFormat.Hm(
      languageTag,
    ).format(reservation.slotEnd.toLocal());

    return Semantics(
      container: true,
      label: l10n.reservationCardSemantic(
        name,
        dateLabel,
        startLabel,
        endLabel,
      ),
      excludeSemantics: true,
      child: Card(
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(dateLabel),
                    Text('$startLabel - $endLabel'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              cancelling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Semantics(
                      button: true,
                      label: l10n.reservationCancelSemantic(name, dateLabel),
                      excludeSemantics: true,
                      child: IconButton(
                        icon: const Icon(Icons.event_busy_outlined),
                        tooltip: l10n.reservationCancelAction,
                        onPressed: onCancel,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  const _EmptyReservations({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.event_available_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyReservationsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.emptyReservationsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
