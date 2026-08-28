import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/session/session_view_model.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/form.dart';
import '../viewmodels/form_detail_view_model.dart';
import '../widgets/form_field_widget.dart';

class FormDetailScreen extends ConsumerWidget {
  const FormDetailScreen({required this.formId, super.key});
  final String formId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<FormDetailUiState> detail = ref.watch(
      formDetailViewModelProvider(formId),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.formDetailTitle)),
      body: detail.when(
        loading: () => Semantics(
          label: l10n.loadingNews,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => FailureView(
          failure: const UnknownFailure(),
          sectionName: l10n.sectionForms,
          onRetry: () =>
              ref.read(formDetailViewModelProvider(formId).notifier).retry(),
        ),
        data: (FormDetailUiState value) {
          if (value.failure != null && value.form == null) {
            return FailureView(
              failure: value.failure!,
              sectionName: l10n.sectionForms,
              onRetry: () => ref
                  .read(formDetailViewModelProvider(formId).notifier)
                  .retry(),
            );
          }
          return _FormDetail(formId: formId, state: value);
        },
      ),
    );
  }
}

class _FormDetail extends ConsumerWidget {
  const _FormDetail({required this.formId, required this.state});
  final String formId;
  final FormDetailUiState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final locale = ref.watch(sessionViewModelProvider).value!.locale;
    final MunicipalForm form = state.form!;
    final ResolvedLocalizedText title = form.title.resolve(locale);
    final ResolvedLocalizedText description = form.description.resolve(locale);
    final notifier = ref.read(formDetailViewModelProvider(formId).notifier);

    if (state.submitted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppIconBadge(
                icon: Icons.check_circle_outline,
                size: AppIconBadgeSize.large,
                backgroundColor: context.semantic.successSurface,
                foregroundColor: context.semantic.success,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.formSubmitted,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final List<FormFieldDefinition> sortedFields =
        List<FormFieldDefinition>.of(form.fields)..sort(
          (FormFieldDefinition a, FormFieldDefinition b) =>
              a.position.compareTo(b.position),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title.text,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(description.text),
              if (form.deadline != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.formDeadlineLabel(
                    DateFormat.yMMMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    ).format(form.deadline!.toLocal()),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (form.alreadySubmitted)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(l10n.formAlreadySubmitted),
                )
              else ...<Widget>[
                for (final FormFieldDefinition field in sortedFields)
                  FormFieldWidget(
                    field: field,
                    value: state.answers[field.id],
                    locale: locale,
                    onChanged: (String value) =>
                        notifier.setAnswer(field.id, value),
                  ),
                if (state.failure != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InlineFailureView(
                      failure: state.failure!,
                      sectionName: l10n.sectionForms,
                      onRetry: notifier.submit,
                    ),
                  ),
                if (form.isOpen)
                  SizedBox(
                    width: double.infinity,
                    height: AppSize.comfortableTouchTarget,
                    child: FilledButton(
                      onPressed: state.canSubmit ? notifier.submit : null,
                      child: state.submitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.formSubmit),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
