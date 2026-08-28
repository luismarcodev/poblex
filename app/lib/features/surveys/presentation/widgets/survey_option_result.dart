import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/l10n/app_locales.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/survey.dart';

/// Read-only bar once results are visible or the option this device voted
/// for is known — never an interactive control, so it never competes with
/// the RadioListTile used while voting is still open.
class SurveyOptionResult extends StatelessWidget {
  const SurveyOptionResult({
    required this.option,
    required this.locale,
    required this.isOwnVote,
    required this.totalVotes,
    super.key,
  });

  final SurveyOption option;
  final AppLocale locale;
  final bool isOwnVote;
  final int totalVotes;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText label = option.label.resolve(locale);
    final int votes = option.votes ?? 0;
    final double fraction = totalVotes == 0 ? 0 : votes / totalVotes;
    final int percent = (fraction * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label.text,
                  style: isOwnVote
                      ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )
                      : Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text('$percent %'),
            ],
          ),
          if (isOwnVote) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.surveyYourVote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.xxs),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: context.semantic.sunkenSurface,
            ),
          ),
        ],
      ),
    );
  }
}
