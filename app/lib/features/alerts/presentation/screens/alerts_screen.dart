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
import '../../domain/entities/alert.dart';
import '../viewmodels/alerts_view_model.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AlertsUiState> alerts = ref.watch(alertsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionAlerts)),
      drawer: const AppDrawer(),
      body: alerts.when(
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
          sectionName: l10n.sectionAlerts,
          onRetry: () => ref.read(alertsViewModelProvider.notifier).refresh(),
        ),
        data: (AlertsUiState state) => _AlertsContent(state: state),
      ),
    );
  }
}

class _AlertsContent extends ConsumerWidget {
  const _AlertsContent({required this.state});
  final AlertsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionViewModelProvider).value?.locale;
    if (locale == null) return const SizedBox.shrink();
    final notifier = ref.read(alertsViewModelProvider.notifier);

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionAlerts,
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.alertIncludeExpiredLabel),
            value: state.includeExpired,
            onChanged: notifier.setIncludeExpired,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.isEmpty)
            const _EmptyAlerts()
          else ...<Widget>[
            for (final MunicipalAlert alert in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AlertCard(
                  alert: alert,
                  locale: locale,
                  onTap: () => context.push('/alerts/${alert.id}'),
                ),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionAlerts,
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
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.notifications_none_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyAlertsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.emptyAlertsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
