import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_alert.dart';
import '../viewmodels/alerts_view_model.dart';
import '../widgets/alert_severity_card.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final alerts = ref.watch(
      alertsViewModelProvider.select(
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
                  ref.read(alertsViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: _AlertsHeader()),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...alerts.when(
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
                                  _ManagedAlertCard(alert: state.items[index]),
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

class _AlertsHeader extends ConsumerWidget {
  const _AlertsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final includeExpired = ref.watch(
      alertsViewModelProvider.select(
        (value) => value.valueOrNull?.includeExpired ?? false,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // The filter and primary action both contain long translated labels.
        // They need a stacked layout well beyond the phone breakpoint when
        // text scaling is enabled.
        final compact = constraints.maxWidth < 960;
        final title = Text(l10n.alertsTitle, style: context.text.headlineLarge);
        final filter = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: includeExpired,
              onChanged: (value) => ref
                  .read(alertsViewModelProvider.notifier)
                  .setIncludeExpired(value),
            ),
            Flexible(child: Text(l10n.includeExpiredAlerts)),
          ],
        );
        final add = FilledButton.icon(
          onPressed: () => context.go('/alertas/nueva'),
          icon: const Icon(Icons.add_alert_outlined),
          label: Text(l10n.newAlert),
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

class _ManagedAlertCard extends ConsumerWidget {
  const _ManagedAlertCard({required this.alert});

  final ManagedAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(
      alertsViewModelProvider.select(
        (value) => value.valueOrNull?.busyIds.contains(alert.id) ?? false,
      ),
    );
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.yMd(locale).add_Hm();
    final severityLabel = _severityLabel(l10n, alert.severity);

    return AlertSeverityCard(
      alert: alert,
      severityLabel: severityLabel,
      phenomenonTypeLabel: _phenomenonTypeLabel(l10n, alert.phenomenonType),
      sourceLabel: alert.source == ManagedAlertSource.manual
          ? l10n.alertSourceManual
          : l10n.alertSourceAemet,
      statusLabel: switch (alert.statusAt(DateTime.now())) {
        ManagedAlertStatus.scheduled => l10n.alertStatusScheduled,
        ManagedAlertStatus.active => l10n.alertStatusActive,
        ManagedAlertStatus.expired => l10n.alertStatusExpired,
      },
      body: alert.body.resolve(Localizations.localeOf(context).languageCode),
      startLabel: l10n.alertStartsAt(formatter.format(alert.startAt.toLocal())),
      endLabel: alert.endAt == null
          ? l10n.alertWithoutEnd
          : l10n.alertEndsAt(formatter.format(alert.endAt!.toLocal())),
      semanticsLabel: l10n.alertCardSemantics(severityLabel, alert.phenomenon),
      editLabel: l10n.edit,
      deleteLabel: l10n.delete,
      createdByLabel: alert.createdBy == null
          ? null
          : l10n.alertCreatedBy(alert.createdBy!),
      updatedByLabel: alert.updatedBy == null
          ? null
          : l10n.alertUpdatedBy(alert.updatedBy!),
      busy: busy,
      onEdit: () => context.go('/alertas/editar/${alert.id}', extra: alert),
      onDelete: () => _confirmDelete(context, ref),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAlertTitle),
        content: Text(l10n.deleteAlertBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final failure = await ref
        .read(alertsViewModelProvider.notifier)
        .delete(alert);
    if (!context.mounted || failure == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_failureMessage(l10n, failure))));
  }
}

class _LoadMoreButton extends ConsumerWidget {
  const _LoadMoreButton({required this.state});

  final AlertsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: state.isLoadingMore
              ? null
              : () async {
                  final failure = await ref
                      .read(alertsViewModelProvider.notifier)
                      .loadMore();
                  if (!context.mounted || failure == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_failureMessage(l10n, failure))),
                  );
                },
          icon: state.isLoadingMore
              ? const SizedBox.square(
                  dimension: AppSize.iconMd,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Icon(Icons.expand_more),
          label: Text(l10n.loadMore),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: Column(
          children: [
            const AppIconBadge(
              icon: Icons.notifications_none,
              size: AppIconBadgeSize.large,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.noAlertsTitle, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.noAlertsBody, textAlign: TextAlign.center),
          ],
        ),
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
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
        child: Column(
          children: [
            Text(_failureMessage(l10n, error), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(alertsViewModelProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

String _severityLabel(AppLocalizations l10n, ManagedAlertSeverity severity) =>
    switch (severity) {
      ManagedAlertSeverity.yellow => l10n.alertSeverityYellow,
      ManagedAlertSeverity.orange => l10n.alertSeverityOrange,
      ManagedAlertSeverity.red => l10n.alertSeverityRed,
    };

String _phenomenonTypeLabel(
  AppLocalizations l10n,
  ManagedAlertPhenomenonType type,
) => switch (type) {
  ManagedAlertPhenomenonType.incendio => l10n.alertPhenomenonTypeIncendio,
  ManagedAlertPhenomenonType.evacuacion => l10n.alertPhenomenonTypeEvacuacion,
  ManagedAlertPhenomenonType.sanitario => l10n.alertPhenomenonTypeSanitario,
  ManagedAlertPhenomenonType.meteorologico =>
    l10n.alertPhenomenonTypeMeteorologico,
  ManagedAlertPhenomenonType.otro => l10n.alertPhenomenonTypeOtro,
};

String _failureMessage(AppLocalizations l10n, Object error) =>
    error is NetworkFailure ? l10n.networkError : l10n.genericError;
