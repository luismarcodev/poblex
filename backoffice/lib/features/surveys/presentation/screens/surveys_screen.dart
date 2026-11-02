import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/text/filename_slug.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_survey.dart';
import '../platform/survey_csv_downloader.dart';
import '../viewmodels/surveys_view_model.dart';

class SurveysScreen extends ConsumerWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final surveys = ref.watch(
      surveysViewModelProvider.select(
        (value) => value.whenData(_SurveyListSnapshot.fromState),
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
                  ref.read(surveysViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      includeClosed:
                          surveys.valueOrNull?.includeClosed ?? false,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                  SliverToBoxAdapter(
                    child: _NonBindingNotice(
                      label: l10n.surveysNonBindingLabel,
                      explanation: l10n.surveysNonBindingExplanation,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...surveys.when(
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
                                  _SurveyCard(survey: state.items[index]),
                            ),
                            if (state.nextCursor != null)
                              SliverToBoxAdapter(
                                child: _LoadMoreButton(
                                  isLoading: state.isLoadingMore,
                                ),
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

class _SurveyListSnapshot extends Equatable {
  const _SurveyListSnapshot({
    required this.items,
    required this.includeClosed,
    required this.nextCursor,
    required this.isLoadingMore,
  });

  factory _SurveyListSnapshot.fromState(SurveysUiState state) =>
      _SurveyListSnapshot(
        items: state.items,
        includeClosed: state.includeClosed,
        nextCursor: state.nextCursor,
        isLoadingMore: state.isLoadingMore,
      );

  final List<ManagedSurvey> items;
  final bool includeClosed;
  final String? nextCursor;
  final bool isLoadingMore;

  @override
  List<Object?> get props => [items, includeClosed, nextCursor, isLoadingMore];
}

class _Header extends ConsumerWidget {
  const _Header({required this.includeClosed});
  final bool includeClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Text(
          l10n.surveysTitle,
          style: context.text.headlineLarge,
        );
        final filter = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: includeClosed,
              onChanged: (value) => ref
                  .read(surveysViewModelProvider.notifier)
                  .setIncludeClosed(value),
            ),
            Flexible(child: Text(l10n.includeClosedSurveys)),
          ],
        );
        final add = FilledButton.icon(
          onPressed: () => context.go('/encuestas/nueva'),
          icon: const Icon(Icons.add),
          label: Text(l10n.newSurvey),
        );
        if (constraints.maxWidth < 900) {
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

class _NonBindingNotice extends StatelessWidget {
  const _NonBindingNotice({required this.label, required this.explanation});
  final String label;
  final String explanation;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ExcludeSemantics(child: Icon(Icons.info_outline, size: 28)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: context.text.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(explanation),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LoadMoreButton extends ConsumerWidget {
  const _LoadMoreButton({required this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: isLoading
              ? null
              : () => _showFailure(
                  context,
                  ref.read(surveysViewModelProvider.notifier).loadMore(),
                ),
          icon: isLoading
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : const Icon(Icons.expand_more),
          label: Text(l10n.loadMore),
        ),
      ),
    );
  }
}

class _SurveyCard extends ConsumerWidget {
  const _SurveyCard({required this.survey});
  final ManagedSurvey survey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final busy = ref.watch(
      surveysViewModelProvider.select(
        (value) => value.valueOrNull?.busyIds.contains(survey.id) ?? false,
      ),
    );
    final locale = Localizations.localeOf(context).languageCode;
    final date = DateFormat.yMMMd(
      locale,
    ).add_Hm().format(survey.closesAt.toLocal());
    final question = survey.question.resolve(locale == 'ca');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Chip(
                  avatar: Icon(
                    survey.isOpen
                        ? Icons.how_to_vote_outlined
                        : Icons.lock_outline,
                    size: 20,
                  ),
                  label: Text(
                    survey.isOpen
                        ? l10n.surveyOpenStatus
                        : l10n.surveyClosedStatus,
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.info_outline, size: 20),
                  label: Text(l10n.surveysNonBindingLabel),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(question, style: context.text.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _MetadataLine(
              icon: Icons.schedule,
              text: survey.isOpen
                  ? l10n.surveyClosesOn(date)
                  : l10n.surveyClosedOn(date),
            ),
            const SizedBox(height: AppSpacing.xs),
            _MetadataLine(
              icon: Icons.format_list_numbered,
              text: l10n.surveyOptionsCount(survey.options.length),
            ),
            const Divider(height: AppSpacing.xl),
            if (busy)
              Semantics(
                liveRegion: true,
                label: l10n.loading,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  TextButton.icon(
                    onPressed: () => _openResults(context, ref),
                    icon: const Icon(Icons.bar_chart_outlined),
                    label: Text(l10n.surveyViewResults),
                  ),
                  if (survey.isOpen)
                    TextButton.icon(
                      onPressed: () => _confirmClose(context, ref),
                      icon: const Icon(Icons.lock_outline),
                      label: Text(l10n.surveyClose),
                    ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openResults(BuildContext context, WidgetRef ref) async {
    final failure = await ref
        .read(surveysViewModelProvider.notifier)
        .loadDetail(survey);
    if (!context.mounted) return;
    if (failure != null) {
      _showFailureMessage(context, failure);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (_) => _SurveyResultsDialog(survey: survey),
    );
  }

  Future<void> _confirmClose(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.surveyCloseTitle),
        content: Text(l10n.surveyCloseBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.surveyClose),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _showFailure(
      context,
      ref.read(surveysViewModelProvider.notifier).close(survey),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSurveyTitle),
        content: Text(l10n.deleteSurveyBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _showFailure(
      context,
      ref.read(surveysViewModelProvider.notifier).delete(survey),
    );
  }
}

class _SurveyResultsDialog extends ConsumerWidget {
  const _SurveyResultsDialog({required this.survey});
  final ManagedSurvey survey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(
      surveysViewModelProvider.select((value) {
        final state = value.valueOrNull;
        return (
          detail: state?.details[survey.id] ?? survey,
          busy: state?.busyIds.contains(survey.id) ?? false,
        );
      }),
    );
    final detail = selected.detail;
    final locale = Localizations.localeOf(context).languageCode;

    return AlertDialog(
      title: Text(l10n.surveyResultsTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                detail.question.resolve(locale == 'ca'),
                style: context.text.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.surveysNonBindingLabel),
              const SizedBox(height: AppSpacing.lg),
              if (!detail.resultsAvailable)
                Semantics(
                  liveRegion: true,
                  child: Text(l10n.surveyResultsHidden),
                )
              else ...[
                Text(
                  l10n.surveyTotalVotes(detail.totalVotes),
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                for (final option in detail.options)
                  _ResultRow(
                    option: option,
                    totalVotes: detail.totalVotes,
                    prefersValencian: locale == 'ca',
                  ),
              ],
              if (selected.busy) ...[
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  liveRegion: true,
                  label: l10n.loading,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (detail.isOpen)
          TextButton.icon(
            onPressed: selected.busy
                ? null
                : () => _showFailure(
                    context,
                    ref
                        .read(surveysViewModelProvider.notifier)
                        .setResultsVisibility(detail, !detail.resultsAvailable),
                  ),
            icon: Icon(
              detail.resultsAvailable
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(
              detail.resultsAvailable
                  ? l10n.surveyHideResults
                  : l10n.surveyShowResults,
            ),
          ),
        TextButton.icon(
          onPressed: selected.busy ? null : () => _export(context, ref, detail),
          icon: const Icon(Icons.download_outlined),
          label: Text(l10n.surveyExportCsv),
        ),
        TextButton(
          onPressed: selected.busy ? null : () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Future<void> _export(
    BuildContext context,
    WidgetRef ref,
    ManagedSurvey detail,
  ) async {
    final result = await ref
        .read(surveysViewModelProvider.notifier)
        .exportResultsCsv(detail);
    if (!context.mounted) return;
    switch (result) {
      case Success(value: final csv):
        downloadSurveyCsv(
          filename: 'resultados-${filenameSlug(detail.question.es)}.csv',
          csv: csv,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).surveyCsvDownloaded),
          ),
        );
      case Failure(error: final error):
        _showFailureMessage(context, error);
    }
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.option,
    required this.totalVotes,
    required this.prefersValencian,
  });

  final ManagedSurveyOption option;
  final int totalVotes;
  final bool prefersValencian;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final votes = option.votes ?? 0;
    final share = totalVotes == 0 ? 0.0 : votes / totalVotes;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        label:
            '${option.label.resolve(prefersValencian)}, ${l10n.surveyVotesCount(votes)}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(option.label.resolve(prefersValencian)),
            const SizedBox(height: AppSpacing.xs),
            LinearProgressIndicator(value: share),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.surveyVotesCount(votes)),
          ],
        ),
      ),
    );
  }
}

class _MetadataLine extends StatelessWidget {
  const _MetadataLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(child: Icon(icon, size: 24)),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text, style: context.text.bodyMedium)),
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
            icon: Icons.poll_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.noSurveysTitle, style: context.text.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.noSurveysBody, textAlign: TextAlign.center),
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
                onPressed: () =>
                    ref.read(surveysViewModelProvider.notifier).refresh(),
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

Future<void> _showFailure(
  BuildContext context,
  Future<AppFailure?> operation,
) async {
  final failure = await operation;
  if (failure != null && context.mounted) {
    _showFailureMessage(context, failure);
  }
}

void _showFailureMessage(BuildContext context, AppFailure failure) {
  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        failure is NetworkFailure ? l10n.networkError : l10n.genericError,
      ),
    ),
  );
}
