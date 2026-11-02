import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/survey.dart';
import '../viewmodels/survey_detail_view_model.dart';
import '../widgets/survey_option_result.dart';

class SurveyDetailScreen extends ConsumerStatefulWidget {
  const SurveyDetailScreen({required this.surveyId, super.key});
  final String surveyId;

  @override
  ConsumerState<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends ConsumerState<SurveyDetailScreen> {
  String? _selectedOptionId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<SurveyDetailUiState> detail = ref.watch(
      surveyDetailViewModelProvider(widget.surveyId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.surveyDetailTitle)),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionSurveys,
          onRetry: () => ref
              .read(surveyDetailViewModelProvider(widget.surveyId).notifier)
              .retry(),
        ),
        data: (SurveyDetailUiState value) {
          if (value.failure != null && value.survey == null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionSurveys,
              onRetry: () => ref
                  .read(surveyDetailViewModelProvider(widget.surveyId).notifier)
                  .retry(),
            );
          }
          return _SurveyDetail(
            survey: value.survey!,
            voting: value.voting,
            selectedOptionId: _selectedOptionId,
            onSelect: (String id) => setState(() => _selectedOptionId = id),
            onVote: () => _vote(context),
          );
        },
      ),
    );
  }

  Future<void> _vote(BuildContext context) async {
    final String? optionId = _selectedOptionId;
    if (optionId == null) return;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final result = await ref
        .read(surveyDetailViewModelProvider(widget.surveyId).notifier)
        .vote(optionId);
    if (!context.mounted || !result.isSuccess) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.surveyVoted)));
  }
}

class _SurveyDetail extends ConsumerWidget {
  const _SurveyDetail({
    required this.survey,
    required this.voting,
    required this.selectedOptionId,
    required this.onSelect,
    required this.onVote,
  });

  final Survey survey;
  final bool voting;
  final String? selectedOptionId;
  final ValueChanged<String> onSelect;
  final VoidCallback onVote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale =
        ref.watch(sessionViewModelProvider).valueOrNull?.locale ?? AppLocale.es;
    final ResolvedLocalizedText question = survey.question.resolve(locale);
    // Voting stays open only while the device hasn't voted and the survey
    // is still open; everything else — including a closed survey this
    // device never voted in — is a read-only view.
    final bool canVote = !survey.hasVoted && survey.isOpen;
    final List<SurveyOption> sortedOptions =
        List<SurveyOption>.of(survey.options)..sort(
          (SurveyOption a, SurveyOption b) => a.position.compareTo(b.position),
        );

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (!survey.binding) Chip(label: Text(l10n.surveyNonBinding)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!canVote && survey.resultsVisible) ...<Widget>[
                  for (final SurveyOption option in sortedOptions)
                    SurveyOptionResult(
                      option: option,
                      locale: locale,
                      isOwnVote: option.id == survey.votedOptionId,
                      totalVotes: survey.totalVotes,
                    ),
                ] else if (!canVote) ...<Widget>[
                  // Voted or closed, but the town hasn't made the tallies
                  // visible yet: naming a winner from null vote counts would
                  // be a fabricated result, so this only confirms the choice.
                  for (final SurveyOption option in sortedOptions)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: option.id == survey.votedOptionId
                          ? const Icon(Icons.check_circle_outline)
                          : const SizedBox(width: AppSize.iconMd),
                      title: Text(option.label.resolve(locale).text),
                      subtitle: option.id == survey.votedOptionId
                          ? Text(l10n.surveyYourVote)
                          : null,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      l10n.surveyResultsHidden,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ] else ...<Widget>[
                  Card(
                    child: RadioGroup<String>(
                      groupValue: selectedOptionId,
                      onChanged: (String? id) {
                        if (id != null) onSelect(id);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final SurveyOption option in sortedOptions)
                            RadioListTile<String>(
                              value: option.id,
                              title: Text(option.label.resolve(locale).text),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: AppSize.comfortableTouchTarget,
                    child: FilledButton(
                      onPressed: selectedOptionId == null || voting
                          ? null
                          : onVote,
                      child: voting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.surveyVote),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
