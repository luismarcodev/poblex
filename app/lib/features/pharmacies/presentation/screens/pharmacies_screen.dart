import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../viewmodels/pharmacies_view_model.dart';
import '../widgets/pharmacy_card.dart';

class PharmaciesScreen extends ConsumerWidget {
  const PharmaciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<PharmaciesUiState> pharmacies = ref.watch(
      pharmaciesViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionPharmacies)),
      drawer: const AppDrawer(),
      body: pharmacies.when(
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
          sectionName: l10n.sectionPharmacies,
          onRetry: () =>
              ref.read(pharmaciesViewModelProvider.notifier).refresh(),
        ),
        data: (PharmaciesUiState state) => _PharmaciesContent(state: state),
      ),
    );
  }
}

class _PharmaciesContent extends ConsumerWidget {
  const _PharmaciesContent({required this.state});
  final PharmaciesUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifier = ref.read(pharmaciesViewModelProvider.notifier);

    if (state.failure != null &&
        state.today == null &&
        state.upcoming.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionPharmacies,
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
          AppSpacing.xxl,
        ),
        children: <Widget>[
          Text(
            l10n.pharmacyTodayTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.today != null)
            PharmacyCard(pharmacy: state.today!, showDate: false)
          else
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Text(l10n.pharmacyNoneToday),
              ),
            ),
          if (state.failure != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: InlineFailureView(
                failure: state.failure!,
                sectionName: l10n.sectionPharmacies,
                onRetry: notifier.refresh,
              ),
            ),
          if (state.upcoming.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.pharmacyUpcomingHeading,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final DutyPharmacy pharmacy in state.upcoming)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: PharmacyCard(pharmacy: pharmacy, showDate: true),
              ),
          ],
        ],
      ),
    );
  }
}
