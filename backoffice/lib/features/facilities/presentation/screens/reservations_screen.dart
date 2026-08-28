import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_facility.dart';
import '../viewmodels/reservations_view_model.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reservations = ref.watch(reservationsViewModelProvider);

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
                  ref.read(reservationsViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _Header()),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                  ...reservations.when(
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
                    data: (state) => [
                      SliverToBoxAdapter(child: _FacilityFilter(state: state)),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.md),
                      ),
                      if (state.items.isEmpty)
                        const SliverToBoxAdapter(child: _EmptyState())
                      else ...[
                        SliverList.builder(
                          itemCount: state.items.length,
                          itemBuilder: (context, index) =>
                              _ReservationCard(
                                reservation: state.items[index],
                                facility: state.facilityFor(
                                  state.items[index].facilityId,
                                ),
                                busy: state.busyIds.contains(
                                  state.items[index].id,
                                ),
                              ),
                        ),
                        if (state.nextCursor != null)
                          SliverToBoxAdapter(
                            child: _LoadMoreButton(state: state),
                          ),
                      ],
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/instalaciones'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(l10n.reservationsTitle, style: context.text.headlineLarge),
        ),
      ],
    );
  }
}

class _FacilityFilter extends ConsumerWidget {
  const _FacilityFilter({required this.state});
  final ReservationsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (state.facilities.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        FilterChip(
          label: Text(l10n.reservationsFilterAll),
          selected: state.facilityFilter == null,
          onSelected: (_) => ref
              .read(reservationsViewModelProvider.notifier)
              .setFacilityFilter(null),
        ),
        for (final facility in state.facilities)
          FilterChip(
            label: Text(facility.name.es),
            selected: state.facilityFilter == facility.id,
            onSelected: (_) => ref
                .read(reservationsViewModelProvider.notifier)
                .setFacilityFilter(facility.id),
          ),
      ],
    );
  }
}

class _LoadMoreButton extends ConsumerWidget {
  const _LoadMoreButton({required this.state});
  final ReservationsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: state.isLoadingMore
              ? null
              : () =>
                    ref.read(reservationsViewModelProvider.notifier).loadMore(),
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

class _ReservationCard extends ConsumerWidget {
  const _ReservationCard({
    required this.reservation,
    required this.facility,
    required this.busy,
  });

  final ManagedReservation reservation;
  final ManagedFacility? facility;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageTag = Localizations.localeOf(context).toLanguageTag();
    final dateLabel = DateFormat.yMMMMEEEEd(
      languageTag,
    ).format(reservation.slotStart.toLocal());
    final startLabel = DateFormat.Hm(
      languageTag,
    ).format(reservation.slotStart.toLocal());
    final endLabel = DateFormat.Hm(
      languageTag,
    ).format(reservation.slotEnd.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility?.name.es ?? l10n.facilitiesTitle,
                    style: context.text.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(dateLabel),
                  Text('$startLabel - $endLabel'),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            busy
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : TextButton.icon(
                    onPressed: () => _confirmCancel(context, ref),
                    icon: const Icon(Icons.event_busy_outlined),
                    label: Text(l10n.reservationCancelAction),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelReservationDialog(),
    );
    if (result == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final failure = await ref
        .read(reservationsViewModelProvider.notifier)
        .cancel(reservationId: reservation.id, note: result);
    if (!context.mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure is NetworkFailure ? l10n.networkError : l10n.genericError,
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reservationCancelledMessage)),
    );
  }
}

class _CancelReservationDialog extends StatefulWidget {
  const _CancelReservationDialog();

  @override
  State<_CancelReservationDialog> createState() =>
      _CancelReservationDialogState();
}

class _CancelReservationDialogState extends State<_CancelReservationDialog> {
  final _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.reservationCancelDialogTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reservationCancelDialogBody),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.reservationCancelNoteLabel,
                errorText: _error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final note = _note.text.trim();
            if (note.isEmpty) {
              setState(() => _error = l10n.requiredField);
              return;
            }
            Navigator.pop(context, note);
          },
          child: Text(l10n.reservationCancelConfirmAction),
        ),
      ],
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
            icon: Icons.event_available_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noReservationsTitle, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.noReservationsBody, textAlign: TextAlign.center),
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
                    ref.read(reservationsViewModelProvider.notifier).refresh(),
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
