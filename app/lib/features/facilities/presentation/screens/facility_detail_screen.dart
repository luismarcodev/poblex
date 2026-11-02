import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/category_label.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/facility.dart';
import '../viewmodels/facility_detail_view_model.dart';

const List<String> _dayKeys = <String>[
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

class FacilityDetailScreen extends ConsumerWidget {
  const FacilityDetailScreen({required this.facilityId, super.key});
  final String facilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLocale locale =
        ref.watch(sessionViewModelProvider).valueOrNull?.locale ?? AppLocale.es;
    final String languageTag = Localizations.localeOf(context).toLanguageTag();

    ref.listen<AsyncValue<FacilityDetailUiState>>(
      facilityDetailViewModelProvider(facilityId),
      (
        AsyncValue<FacilityDetailUiState>? previous,
        AsyncValue<FacilityDetailUiState> next,
      ) {
        final AvailabilitySlot? previousBooked = previous?.value?.bookedSlot;
        final AvailabilitySlot? nextBooked = next.value?.bookedSlot;
        if (nextBooked != null && nextBooked != previousBooked) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Semantics(
                  liveRegion: true,
                  child: Text(l10n.facilityBookedSnackbar),
                ),
              ),
            );
        }
      },
    );

    final AsyncValue<FacilityDetailUiState> detail = ref.watch(
      facilityDetailViewModelProvider(facilityId),
    );
    final Facility? facility = detail.valueOrNull?.facility;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          facility != null
              ? facility.name.resolve(locale).text
              : l10n.facilityDetailTitle,
        ),
      ),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loading,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionFacilities,
          onRetry: () =>
              ref.invalidate(facilityDetailViewModelProvider(facilityId)),
        ),
        data: (FacilityDetailUiState state) {
          if (state.facility == null) {
            return FailureView(
              failure: state.failure ?? const UnknownFailure(),
              sectionName: l10n.sectionFacilities,
              onRetry: () =>
                  ref.invalidate(facilityDetailViewModelProvider(facilityId)),
            );
          }
          return _FacilityDetailContent(
            facilityId: facilityId,
            state: state,
            locale: locale,
            languageTag: languageTag,
          );
        },
      ),
    );
  }
}

class _FacilityDetailContent extends ConsumerWidget {
  const _FacilityDetailContent({
    required this.facilityId,
    required this.state,
    required this.locale,
    required this.languageTag,
  });

  final String facilityId;
  final FacilityDetailUiState state;
  final AppLocale locale;
  final String languageTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Facility facility = state.facility!;
    final notifier = ref.read(
      facilityDetailViewModelProvider(facilityId).notifier,
    );
    final int horizonDays = facility.maxAdvanceBookingDays.clamp(1, 30);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Chip(label: Text(prettifyCategorySlug(facility.category))),
                if (facility.description != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    facility.description!.resolve(locale).text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (facility.feeNote != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  _InfoCard(
                    icon: Icons.payments_outlined,
                    heading: l10n.facilityFeeNoteHeading,
                    body: facility.feeNote!.resolve(locale).text,
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.facilityOpeningHoursHeading,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _OpeningHoursTable(
                  facility: facility,
                  languageTag: languageTag,
                  l10n: l10n,
                ),
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.facilitySelectDateHeading,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _DatePicker(
                  anchorDate: _tomorrow(),
                  selectedDate: state.selectedDate,
                  horizonDays: horizonDays,
                  languageTag: languageTag,
                  onSelected: notifier.selectDate,
                ),
                const SizedBox(height: AppSpacing.lg),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.facilitySlotsHeading,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (state.failure != null)
                  InlineFailureView(
                    failure: state.failure!,
                    sectionName: l10n.sectionFacilities,
                    onRetry: () => notifier.selectDate(state.selectedDate),
                  )
                else if (state.loadingSlots)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.slots.isEmpty)
                  _EmptySlots(l10n: l10n)
                else
                  _SlotsGrid(
                    facility: facility,
                    slots: state.slots,
                    booking: state.booking,
                    locale: locale,
                    languageTag: languageTag,
                    onBook: (AvailabilitySlot slot) => _confirmBooking(
                      context,
                      notifier,
                      facility,
                      slot,
                      l10n,
                      languageTag,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _tomorrow() {
    final DateTime today = DateTime.now().toUtc();
    return DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).add(const Duration(days: 1));
  }

  Future<void> _confirmBooking(
    BuildContext context,
    FacilityDetailViewModel notifier,
    Facility facility,
    AvailabilitySlot slot,
    AppLocalizations l10n,
    String languageTag,
  ) async {
    final String dateLabel = DateFormat.yMMMMEEEEd(
      languageTag,
    ).format(slot.start.toLocal());
    final String startLabel = DateFormat.Hm(
      languageTag,
    ).format(slot.start.toLocal());
    final String endLabel = DateFormat.Hm(
      languageTag,
    ).format(slot.end.toLocal());
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(l10n.facilityBookConfirmTitle),
        content: Text(
          l10n.facilityBookConfirmBody(
            facility.name.resolve(locale).text,
            dateLabel,
            startLabel,
            endLabel,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.facilityBookConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await notifier.book(slot);
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.heading,
    required this.body,
  });

  final IconData icon;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExcludeSemantics(child: Icon(icon)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(heading, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpeningHoursTable extends StatelessWidget {
  const _OpeningHoursTable({
    required this.facility,
    required this.languageTag,
    required this.l10n,
  });

  final Facility facility;
  final String languageTag;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Referencia arbitraria de lunes para poder formatear el nombre de cada
    // día con intl en el idioma activo, sin duplicar los nombres en ARB.
    final DateTime monday = DateTime.utc(2026, 8, 10);
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          children: <Widget>[
            for (int index = 0; index < _dayKeys.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        DateFormat.EEEE(
                          languageTag,
                        ).format(monday.add(Duration(days: index))),
                      ),
                    ),
                    Text(_rangeLabel(index)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _rangeLabel(int index) {
    final FacilityDayHours? range = facility.openingHours[_dayKeys[index]];
    if (range == null) return l10n.facilityOpeningHoursClosed;
    return '${range.open} - ${range.close}';
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.anchorDate,
    required this.selectedDate,
    required this.horizonDays,
    required this.languageTag,
    required this.onSelected,
  });

  /// Primer día del selector — estable mientras la pantalla vive, no se
  /// recalcula al elegir un día distinto (evita que la ventana de fechas se
  /// desplace sola cuando el usuario toca un chip que no sea el primero).
  final DateTime anchorDate;
  final DateTime selectedDate;
  final int horizonDays;
  final String languageTag;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: horizonDays,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.xs),
        itemBuilder: (BuildContext context, int index) {
          final DateTime date = anchorDate.add(Duration(days: index));
          return _DateChip(
            date: date,
            selected: _isSameDay(date, selectedDate),
            languageTag: languageTag,
            onTap: () => onSelected(date),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.selected,
    required this.languageTag,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final String languageTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = DateFormat.MMMd(languageTag).format(date);
    final String weekday = DateFormat.E(languageTag).format(date);
    return Semantics(
      button: true,
      selected: selected,
      label: DateFormat.yMMMMEEEEd(languageTag).format(date),
      excludeSemantics: true,
      child: ChoiceChip(
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(weekday, style: Theme.of(context).textTheme.labelSmall),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  const _SlotsGrid({
    required this.facility,
    required this.slots,
    required this.booking,
    required this.locale,
    required this.languageTag,
    required this.onBook,
  });

  final Facility facility;
  final List<AvailabilitySlot> slots;
  final bool booking;
  final AppLocale locale;
  final String languageTag;
  final ValueChanged<AvailabilitySlot> onBook;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final AvailabilitySlot slot in slots)
          _SlotChip(
            slot: slot,
            enabled: !booking,
            languageTag: languageTag,
            semanticLabel: l10n.facilitySlotSemantic(
              DateFormat.Hm(languageTag).format(slot.start.toLocal()),
              DateFormat.Hm(languageTag).format(slot.end.toLocal()),
            ),
            onTap: () => onBook(slot),
          ),
      ],
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.enabled,
    required this.languageTag,
    required this.semanticLabel,
    required this.onTap,
  });

  final AvailabilitySlot slot;
  final bool enabled;
  final String languageTag;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = DateFormat.Hm(
      languageTag,
    ).format(slot.start.toLocal());
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      excludeSemantics: true,
      child: ActionChip(
        avatar: const Icon(Icons.schedule_outlined, size: 16),
        label: Text(label),
        onPressed: enabled ? onTap : null,
      ),
    );
  }
}

class _EmptySlots extends StatelessWidget {
  const _EmptySlots({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.event_busy_outlined,
            size: AppIconBadgeSize.medium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.emptyFacilitySlotsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(l10n.emptyFacilitySlotsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
