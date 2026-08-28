import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/incident.dart';
import '../viewmodels/my_incidents_view_model.dart';
import '../widgets/incident_category_field.dart';
import '../widgets/incident_status_chip.dart';

class MyIncidentsScreen extends ConsumerWidget {
  const MyIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<MyIncidentsUiState> incidents = ref.watch(
      myIncidentsViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionIncidents)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/incidents/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.incidentReportTitle),
      ),
      body: incidents.when(
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
                const AppSkeleton(height: 96),
          ),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionIncidents,
          onRetry: () =>
              ref.read(myIncidentsViewModelProvider.notifier).refresh(),
        ),
        data: (MyIncidentsUiState state) => _MyIncidentsContent(state: state),
      ),
    );
  }
}

class _MyIncidentsContent extends ConsumerWidget {
  const _MyIncidentsContent({required this.state});
  final MyIncidentsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final notifier = ref.read(myIncidentsViewModelProvider.notifier);

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionIncidents,
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
            const _EmptyIncidents()
          else ...<Widget>[
            for (final Incident incident in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _IncidentTile(incident: incident),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionIncidents,
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

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String categoryLabel = incidentCategoryLabel(l10n, incident.category);
    final String date = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(incident.createdAt.toLocal());

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$categoryLabel. ${incident.description}. $date',
      child: Card(
        child: InkWell(
          onTap: () => context.push('/incidents/${incident.id}'),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        categoryLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        incident.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(date),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IncidentStatusChip(status: incident.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyIncidents extends StatelessWidget {
  const _EmptyIncidents();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.report_gmailerrorred_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyIncidentsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.emptyIncidentsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
