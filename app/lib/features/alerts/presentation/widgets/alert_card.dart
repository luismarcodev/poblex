import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/l10n/app_locales.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/alert.dart';
import 'severity_presentation.dart';

/// R1: no brand colour appears anywhere in this widget. R2: solid fill for
/// severity, never an outline. R3: colour + icon shape + text label + bar
/// width, all four redundant. R4/R5: bar width grows with level; corner
/// radius uses the alert-reserved token, never the 16dp content radius.
class AlertCard extends StatelessWidget {
  const AlertCard({
    required this.alert,
    required this.locale,
    required this.onTap,
    super.key,
  });

  final MunicipalAlert alert;
  final AppLocale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final SeverityColors palette = context.semantic.of(
      toDesignSeverity(alert.severity),
    );
    final ResolvedLocalizedText body = alert.body.resolve(locale);
    final bool active = alert.isActiveAt(DateTime.now());
    final String severityLabel = l10n.alertSeverityLabel(alert.severity.slug);
    final String dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(alert.startAt.toLocal());
    final String statusLabel = active
        ? l10n.alertActiveLabel
        : l10n.alertExpiredLabel;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$severityLabel. ${alert.phenomenon}. $statusLabel. $dateLabel',
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xsAll,
          side: BorderSide(color: palette.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: toDesignSeverity(alert.severity).barWidth,
                  color: palette.bar,
                ),
                Expanded(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: <Widget>[
                            SeverityBadge(
                              label: severityLabel,
                              severity: alert.severity,
                              palette: palette,
                            ),
                            if (alert.phenomenonType !=
                                    AlertPhenomenonType.meteorologico &&
                                alert.phenomenonType !=
                                    AlertPhenomenonType.otro)
                              Chip(
                                avatar: ExcludeSemantics(
                                  child: Icon(
                                    phenomenonIcon(
                                      alert.phenomenonType,
                                      alert.severity,
                                    ),
                                    color: palette.heading,
                                    size: AppSize.iconSm,
                                  ),
                                ),
                                labelStyle: TextStyle(color: palette.heading),
                                label: Text(
                                  l10n.alertPhenomenonTypeLabel(
                                    alert.phenomenonType.slug,
                                  ),
                                ),
                                side: BorderSide(color: palette.border),
                              ),
                            if (!active)
                              Chip(
                                labelStyle: TextStyle(color: palette.heading),
                                label: Text(statusLabel),
                                side: BorderSide(color: palette.border),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          alert.phenomenon,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: palette.heading),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          body.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: palette.onSurface),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          dateLabel,
                          style: TextStyle(color: palette.onSurface),
                        ),
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
