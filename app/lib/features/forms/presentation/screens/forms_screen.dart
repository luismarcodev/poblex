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
import '../../domain/entities/form.dart';
import '../viewmodels/forms_view_model.dart';

class FormsScreen extends ConsumerWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<FormsUiState> forms = ref.watch(formsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sectionForms)),
      drawer: const AppDrawer(),
      body: forms.when(
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
          sectionName: l10n.sectionForms,
          onRetry: () => ref.read(formsViewModelProvider.notifier).refresh(),
        ),
        data: (FormsUiState state) => _FormsContent(state: state),
      ),
    );
  }
}

class _FormsContent extends ConsumerWidget {
  const _FormsContent({required this.state});
  final FormsUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionViewModelProvider).value?.locale;
    if (locale == null) return const SizedBox.shrink();
    final notifier = ref.read(formsViewModelProvider.notifier);

    if (state.failure != null && state.isEmpty) {
      return FailureView(
        failure: state.failure!,
        sectionName: l10n.sectionForms,
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
            title: Text(l10n.formIncludeClosedLabel),
            value: state.includeClosed,
            onChanged: notifier.setIncludeClosed,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (state.isEmpty)
            const _EmptyForms()
          else ...<Widget>[
            for (final MunicipalForm form in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _FormTile(form: form, locale: locale),
              ),
            if (state.failure != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: InlineFailureView(
                  failure: state.failure!,
                  sectionName: l10n.sectionForms,
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

class _FormTile extends StatelessWidget {
  const _FormTile({required this.form, required this.locale});
  final MunicipalForm form;
  final AppLocale locale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText title = form.title.resolve(locale);
    final String? deadlineLabel = form.deadline == null
        ? null
        : l10n.formDeadlineLabel(
            DateFormat.yMMMd(
              Localizations.localeOf(context).toLanguageTag(),
            ).format(form.deadline!.toLocal()),
          );

    return Semantics(
      button: true,
      excludeSemantics: true,
      label:
          '${title.text}. ${form.alreadySubmitted ? l10n.formAlreadySubmitted : deadlineLabel ?? ''}',
      child: Card(
        child: InkWell(
          onTap: () => context.push('/forms/${form.id}'),
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title.text,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: <Widget>[
                    if (form.alreadySubmitted)
                      Chip(label: Text(l10n.formAlreadySubmitted)),
                    if (!form.isOpen)
                      Chip(label: Text(l10n.surveyClosedLabel))
                    else if (deadlineLabel != null)
                      Chip(label: Text(deadlineLabel)),
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

class _EmptyForms extends StatelessWidget {
  const _EmptyForms();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.huge),
      child: Column(
        children: <Widget>[
          const AppIconBadge(
            icon: Icons.assignment_outlined,
            size: AppIconBadgeSize.large,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.emptyFormsTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.emptyFormsBody, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
