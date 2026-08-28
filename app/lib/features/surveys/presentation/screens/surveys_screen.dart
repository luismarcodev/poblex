import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/l10n/app_locales.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/app_drawer.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../domain/entities/survey.dart';
import '../viewmodels/surveys_view_model.dart';

class SurveysScreen extends ConsumerWidget {
  const SurveysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<SurveysUiState> surveys = ref.watch(
      surveysViewModelProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionSurveys)),
      drawer: const AppDrawer(),
      body: surveys.when(
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
          sectionName: l10n.sectionSurveys,
          onRetry: () => ref.read(surveysViewModelProvider.notifier).refresh(),
        ),
        data: (SurveysUiState state) => _SurveysContent(state: state),
      ),
    );
  }
}

class _SurveysContent extends ConsumerWidget {
  const _SurveysContent({required this.state});
  final SurveysUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionViewModelProvider).value?.locale;
    if (locale == null) return const SizedBox.shrink();
    final notifier = ref.read(surveysViewModelProvider.notifier);

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionSurveys,
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
            title: Text(l10n.surveyIncludeClosedLabel),
            value: state.includeClosed,
            onChanged: notifier.setIncludeClosed,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.isEmpty)
            const _EmptySurveys()
          else ...<Widget>[
            for (final Survey survey in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SurveyTile(survey: survey, locale: locale),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionSurveys,
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

class _SurveyTile extends StatelessWidget {
  const _SurveyTile({required this.survey, required this.locale});
  final Survey survey;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText question = survey.question.resolve(locale);
    final String closesLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(survey.closesAt.toLocal());

    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${question.text}. ${survey.isOpen ? closesLabel : l10n.surveyClosedLabel}',
      child: Card(
        child: InkWell(
          onTap: () => context.push('/surveys/${survey.id}'),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    if (!survey.isOpen)
                      Chip(label: Text(l10n.surveyClosedLabel))
                    else
                      Chip(label: Text(closesLabel)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySurveys extends StatelessWidget {
  const _EmptySurveys();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.poll_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptySurveysTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.emptySurveysBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
