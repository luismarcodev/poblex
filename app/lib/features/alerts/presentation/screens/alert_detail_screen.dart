import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/alert.dart';
import '../viewmodels/alert_detail_view_model.dart';
import '../widgets/severity_presentation.dart';

class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({required this.alertId, super.key});
  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AlertDetailUiState> detail = ref.watch(
      alertDetailViewModelProvider(alertId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertDetailTitle)),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionAlerts,
          onRetry: () =>
              ref.read(alertDetailViewModelProvider(alertId).notifier).retry(),
        ),
        data: (AlertDetailUiState value) {
          if (value.failure != null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionAlerts,
              onRetry: () => ref
                  .read(alertDetailViewModelProvider(alertId).notifier)
                  .retry(),
            );
          }
          return _AlertDetail(alert: value.alert!);
        },
      ),
    );
  }
}

class _AlertDetail extends ConsumerWidget {
  const _AlertDetail({required this.alert});
  final MunicipalAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale =
        ref.watch(sessionViewModelProvider).valueOrNull?.locale ?? AppLocale.es;
    final ResolvedLocalizedText body = alert.body.resolve(locale);
    final SeverityColors palette = context.semantic.of(
      toDesignSeverity(alert.severity),
    );
    final bool active = alert.isActiveAt(DateTime.now());
    final String severityLabel = l10n.alertSeverityLabel(alert.severity.slug);
    final String languageTag = Localizations.localeOf(context).toLanguageTag();
    final String startLabel = DateFormat.yMMMMEEEEd(
      languageTag,
    ).format(alert.startAt.toLocal());
    final String? endLabel = alert.endAt == null
        ? null
        : DateFormat.yMMMMEEEEd(languageTag).format(alert.endAt!.toLocal());

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: AppRadius.xsAll,
              border: Border.all(color: palette.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: toDesignSeverity(alert.severity).barWidth,
                  decoration: BoxDecoration(
                    color: palette.bar,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.xs),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: <Widget>[
                            Chip(
                              backgroundColor: palette.identity,
                              side: BorderSide.none,
                              avatar: ExcludeSemantics(
                                child: Icon(
                                  phenomenonIcon(
                                    alert.phenomenonType,
                                    alert.severity,
                                  ),
                                  size: AppSize.iconSm,
                                  color: palette.onIdentity,
                                ),
                              ),
                              label: Text(
                                severityLabel,
                                style: TextStyle(color: palette.onIdentity),
                              ),
                            ),
                            if (alert.phenomenonType !=
                                    AlertPhenomenonType.meteorologico &&
                                alert.phenomenonType !=
                                    AlertPhenomenonType.otro)
                              Chip(
                                label: Text(
                                  l10n.alertPhenomenonTypeLabel(
                                    alert.phenomenonType.slug,
                                  ),
                                ),
                                side: BorderSide(color: palette.border),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          alert.phenomenon,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: palette.heading),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          active
                              ? l10n.alertActiveLabel
                              : l10n.alertExpiredLabel,
                          style: TextStyle(color: palette.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          endLabel == null
                              ? startLabel
                              : '$startLabel — $endLabel',
                          style: TextStyle(color: palette.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          body.text,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: palette.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          alert.source == AlertSource.aemet
                              ? l10n.alertSourceAemet
                              : l10n.alertSourceManual,
                          style: TextStyle(color: palette.onSurface),
                        ),
                        if (alert.forcesNotification) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: <Widget>[
                              ExcludeSemantics(
                                child: Icon(
                                  Icons.priority_high,
                                  size: AppSize.iconSm,
                                  color: palette.heading,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  l10n.alertForcedNotice,
                                  style: TextStyle(color: palette.heading),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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
