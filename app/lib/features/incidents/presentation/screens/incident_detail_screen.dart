import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/incident.dart';
import '../viewmodels/incident_detail_view_model.dart';
import '../widgets/incident_category_field.dart';
import '../widgets/incident_status_chip.dart';

class IncidentDetailScreen extends ConsumerWidget {
  const IncidentDetailScreen({required this.incidentId, super.key});
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<IncidentDetailUiState> detail = ref.watch(
      incidentDetailViewModelProvider(incidentId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.incidentDetailTitle)),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionIncidents,
          onRetry: () => ref
              .read(incidentDetailViewModelProvider(incidentId).notifier)
              .retry(),
        ),
        data: (IncidentDetailUiState value) {
          if (value.failure != null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionIncidents,
              onRetry: () => ref
                  .read(incidentDetailViewModelProvider(incidentId).notifier)
                  .retry(),
            );
          }
          return _IncidentDetail(detail: value.detail!);
        },
      ),
    );
  }
}

class _IncidentDetail extends StatelessWidget {
  const _IncidentDetail({required this.detail});
  final IncidentDetail detail;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Incident incident = detail.incident;
    final String languageTag = Localizations.localeOf(context).toLanguageTag();

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        incidentCategoryLabel(l10n, incident.category),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IncidentStatusChip(status: incident.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(incident.description),
                if (incident.photoUrl != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: AppRadius.lgAll,
                    child: CachedNetworkImage(
                      imageUrl: incident.photoUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.incidentHistoryHeading,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final IncidentStatusChange change in detail.history)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ExcludeSemantics(
                          child: Icon(
                            Icons.circle,
                            size: AppSize.iconSm,
                            color: context.semantic.brandGraphic,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              IncidentStatusChip(status: change.status),
                              if (change.note != null) ...<Widget>[
                                const SizedBox(height: AppSpacing.xxs),
                                Text(change.note!),
                              ],
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                DateFormat.yMMMd(
                                  languageTag,
                                ).add_Hm().format(change.changedAt.toLocal()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
