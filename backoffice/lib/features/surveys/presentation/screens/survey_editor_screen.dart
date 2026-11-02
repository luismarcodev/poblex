import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/text/optional_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_survey.dart';
import '../viewmodels/survey_editor_view_model.dart';

class SurveyEditorScreen extends ConsumerStatefulWidget {
  const SurveyEditorScreen({super.key});

  @override
  ConsumerState<SurveyEditorScreen> createState() => _SurveyEditorScreenState();
}

class _SurveyEditorScreenState extends ConsumerState<SurveyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionEs = TextEditingController();
  final _questionVa = TextEditingController();
  final _options = <_OptionControllers>[
    _OptionControllers(),
    _OptionControllers(),
  ];
  late DateTime _closesAt;
  bool _resultsVisible = false;
  String? _closingError;

  @override
  void initState() {
    super.initState();
    _closesAt = DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _questionEs.dispose();
    _questionVa.dispose();
    for (final option in _options) {
      option.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final saving = ref.watch(
      surveyEditorViewModelProvider.select((value) => value.isLoading),
    );
    final municipality = ref.watch(
      selectedMunicipalityProvider.select(
        (value) => (id: value.id, name: value.name),
      ),
    );

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSize.maxWorkspaceWidth,
          ),
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EditorHeader(onBack: () => context.go('/encuestas')),
                  const SizedBox(height: AppSpacing.lg),
                  _NonBindingEditorNotice(
                    title: l10n.surveysNonBindingLabel,
                    body: l10n.surveysNonBindingExplanation,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _QuestionFields(spanish: _questionEs, valencian: _questionVa),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.surveyOptionsTitle, style: context.text.titleLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l10n.surveyMinimumOptions),
                  const SizedBox(height: AppSpacing.md),
                  for (var index = 0; index < _options.length; index++) ...[
                    _OptionFields(
                      key: ValueKey(_options[index]),
                      index: index,
                      controllers: _options[index],
                      canRemove: _options.length > 2,
                      onRemove: () => _removeOption(index),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: saving ? null : _addOption,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.surveyAddOption),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _ClosingDateField(
                    closesAt: _closesAt,
                    errorText: _closingError,
                    onChange: saving ? null : _pickClosingDate,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.surveyResultsVisibleFromStart),
                    value: _resultsVisible,
                    onChanged: saving
                        ? null
                        : (value) => setState(() => _resultsVisible = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.municipalityLabel,
                    ),
                    child: Text(municipality.name),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        OutlinedButton(
                          onPressed: saving
                              ? null
                              : () => context.go('/encuestas'),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton.icon(
                          key: const Key('publish-survey'),
                          onPressed: saving
                              ? null
                              : () => _submit(municipality.id),
                          icon: saving
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.publish),
                          label: Text(l10n.publishSurvey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addOption() => setState(() => _options.add(_OptionControllers()));

  void _removeOption(int index) {
    if (_options.length <= 2) return;
    final removed = _options.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _pickClosingDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _closesAt,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_closesAt),
    );
    if (time == null) return;
    setState(() {
      _closesAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _closingError = null;
    });
  }

  Future<void> _submit(String municipalityId) async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    final closingValid = _closesAt.isAfter(DateTime.now());
    if (!closingValid) {
      setState(() => _closingError = l10n.surveyFutureClosingRequired);
    }
    if (!formValid || !closingValid) return;

    final failure = await ref
        .read(surveyEditorViewModelProvider.notifier)
        .create(
          CreateSurveyInput(
            municipalityId: municipalityId,
            question: SurveyLocalizedText(
              es: _questionEs.text,
              va: optionalText(_questionVa.text),
            ),
            closesAt: _closesAt,
            resultsVisible: _resultsVisible,
            options: _options
                .map(
                  (option) => SurveyLocalizedText(
                    es: option.spanish.text,
                    va: optionalText(option.valencian.text),
                  ),
                )
                .toList(growable: false),
          ),
        );
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_failureMessage(l10n, failure))));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.surveyCreatedMessage)));
    context.go('/encuestas');
  }

  String _failureMessage(AppLocalizations l10n, AppFailure failure) {
    if (failure is NetworkFailure) return l10n.networkError;
    if (failure is ValidationFailure &&
        failure.message == 'survey_future_closing') {
      return l10n.surveyFutureClosingRequired;
    }
    if (failure is ValidationFailure &&
        failure.message == 'survey_minimum_options') {
      return l10n.surveyMinimumOptions;
    }
    return l10n.genericError;
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            l10n.surveyCreateTitle,
            style: context.text.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _NonBindingEditorNotice extends StatelessWidget {
  const _NonBindingEditorNotice({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
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
                Text(title, style: context.text.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuestionFields extends StatelessWidget {
  const _QuestionFields({required this.spanish, required this.valencian});
  final TextEditingController spanish;
  final TextEditingController valencian;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spanishField = TextFormField(
      key: const Key('survey-question-es'),
      controller: spanish,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(labelText: l10n.surveyQuestionSpanish),
      validator: (value) =>
          value == null || value.trim().isEmpty ? l10n.requiredField : null,
    );
    final valencianField = TextFormField(
      key: const Key('survey-question-va'),
      controller: valencian,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(labelText: l10n.surveyQuestionValencian),
    );
    return _AdaptivePair(first: spanishField, second: valencianField);
  }
}

class _OptionFields extends StatelessWidget {
  const _OptionFields({
    required this.index,
    required this.controllers,
    required this.canRemove,
    required this.onRemove,
    super.key,
  });

  final int index;
  final _OptionControllers controllers;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final number = index + 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                key: Key('remove-survey-option-$index'),
                onPressed: canRemove ? onRemove : null,
                tooltip: l10n.surveyRemoveOption(number),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
            _AdaptivePair(
              first: TextFormField(
                key: Key('survey-option-es-$index'),
                controller: controllers.spanish,
                decoration: InputDecoration(
                  labelText: l10n.surveyOptionSpanish(number),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              second: TextFormField(
                key: Key('survey-option-va-$index'),
                controller: controllers.valencian,
                decoration: InputDecoration(
                  labelText: l10n.surveyOptionValencian(number),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdaptivePair extends StatelessWidget {
  const _AdaptivePair({required this.first, required this.second});
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 900) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: second),
          ],
        );
      }
      return Column(
        children: [
          first,
          const SizedBox(height: AppSpacing.md),
          second,
        ],
      );
    },
  );
}

class _ClosingDateField extends StatelessWidget {
  const _ClosingDateField({
    required this.closesAt,
    required this.onChange,
    this.errorText,
  });

  final DateTime closesAt;
  final VoidCallback? onChange;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.surveyClosingDate,
        errorText: errorText,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            DateFormat.yMMMd(locale).add_Hm().format(closesAt),
            style: context.text.bodyLarge,
          ),
          OutlinedButton.icon(
            onPressed: onChange,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(l10n.surveyChangeClosingDate),
          ),
        ],
      ),
    );
  }
}

class _OptionControllers {
  final spanish = TextEditingController();
  final valencian = TextEditingController();

  void dispose() {
    spanish.dispose();
    valencian.dispose();
  }
}
