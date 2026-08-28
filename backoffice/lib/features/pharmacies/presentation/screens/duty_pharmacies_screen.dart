import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../viewmodels/duty_pharmacies_view_model.dart';

class DutyPharmaciesScreen extends ConsumerWidget {
  const DutyPharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final pharmacies = ref.watch(dutyPharmaciesViewModelProvider);
    final month = pharmacies.valueOrNull?.month ?? DateTime.now();

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
                  ref.read(dutyPharmaciesViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _Header(month: month)),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...pharmacies.when(
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
                                  _PharmacyCard(pharmacy: state.items[index]),
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
  const _Header({required this.month});

  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final monthLabel = DateFormat.yMMMM(locale).format(month);
    final viewModel = ref.read(dutyPharmaciesViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final heading = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.pharmaciesTitle, style: context.text.headlineLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.pharmaciesSubtitle),
              ],
            );
            final addButton = FilledButton.icon(
              onPressed: () async {
                await context.push('/farmacias/nueva');
                if (context.mounted) {
                  ref.read(dutyPharmaciesViewModelProvider.notifier).refresh();
                }
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.newDutyPharmacy),
            );
            if (constraints.maxWidth < 720) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading,
                  const SizedBox(height: AppSpacing.md),
                  addButton,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: AppSpacing.md),
                addButton,
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                IconButton(
                  onPressed: viewModel.showPreviousMonth,
                  tooltip: l10n.previousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 160),
                  child: Text(
                    monthLabel,
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: viewModel.showNextMonth,
                  tooltip: l10n.nextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
                OutlinedButton(
                  onPressed: viewModel.showCurrentMonth,
                  child: Text(l10n.currentMonth),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PharmacyCard extends ConsumerWidget {
  const _PharmacyCard({required this.pharmacy});

  final DutyPharmacy pharmacy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat.yMMMMEEEEd(locale).format(pharmacy.date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(date, style: context.text.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(pharmacy.pharmacyName, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _MetadataLine(
              icon: Icons.place_outlined,
              label: l10n.dutyPharmacyAddressLabel,
              value: pharmacy.address,
            ),
            const SizedBox(height: AppSpacing.xs),
            _MetadataLine(
              icon: Icons.phone_outlined,
              label: l10n.dutyPharmacyPhoneLabel,
              value: pharmacy.phone,
            ),
            const SizedBox(height: AppSpacing.xs),
            _MetadataLine(
              icon: Icons.schedule_outlined,
              label: l10n.dutyPharmacyScheduleLabel,
              value: pharmacy.schedule,
            ),
            const Divider(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () async {
                  final dateValue = _formatRouteDate(pharmacy.date);
                  await context.push(
                    '/farmacias/editar/${pharmacy.municipalityId}/$dateValue',
                    extra: pharmacy,
                  );
                  if (context.mounted) {
                    ref
                        .read(dutyPharmaciesViewModelProvider.notifier)
                        .refresh();
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editDutyPharmacy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRouteDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(child: Icon(icon, size: 24)),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Semantics(
          label: '$label: $value',
          child: ExcludeSemantics(
            child: Text(value, style: context.text.bodyLarge),
          ),
        ),
      ),
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
            icon: Icons.local_pharmacy_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noDutyPharmaciesTitle, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.noDutyPharmaciesBody, textAlign: TextAlign.center),
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
                onPressed: () => ref
                    .read(dutyPharmaciesViewModelProvider.notifier)
                    .refresh(),
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
