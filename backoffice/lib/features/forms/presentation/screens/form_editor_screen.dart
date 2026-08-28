import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_form.dart';
import '../forms_copy.dart';
import '../viewmodels/form_editor_view_model.dart';

class FormEditorScreen extends ConsumerStatefulWidget {
  const FormEditorScreen({
    required this.onCancel,
    required this.onCreated,
    this.copy,
    super.key,
  });

  final FormsCopy? copy;
  final VoidCallback onCancel;
  final VoidCallback onCreated;

  @override
  ConsumerState<FormEditorScreen> createState() => _FormEditorScreenState();
}

class _FormEditorScreenState extends ConsumerState<FormEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEs = TextEditingController();
  final _titleVa = TextEditingController();
  final _descriptionEs = TextEditingController();
  final _descriptionVa = TextEditingController();
  final List<_FieldControllers> _fields = [_FieldControllers()];
  DateTime? _deadline;
  String? _deadlineError;
  late FormsCopy _copy;

  @override
  void dispose() {
    _titleEs.dispose();
    _titleVa.dispose();
    _descriptionEs.dispose();
    _descriptionVa.dispose();
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _copy = widget.copy ?? AppFormsCopy(AppLocalizations.of(context));
    final municipalityId = ref.watch(
      selectedMunicipalityProvider.select((municipality) => municipality.id),
    );
    final saving = ref.watch(
      formEditorViewModelProvider.select((value) => value.isLoading),
    );
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: AppSpacing.screenPadding,
                  sliver: SliverList.list(
                    children: [
                      _EditorHeader(copy: _copy, onBack: widget.onCancel),
                      const SizedBox(height: AppSpacing.lg),
                      _LocalizedPair(
                        first: TextFormField(
                          key: const Key('form-title-es'),
                          controller: _titleEs,
                          decoration: InputDecoration(
                            labelText: _copy.titleSpanish,
                          ),
                          validator: _required,
                        ),
                        second: TextFormField(
                          key: const Key('form-title-va'),
                          controller: _titleVa,
                          decoration: InputDecoration(
                            labelText: _copy.titleValencian,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _LocalizedPair(
                        first: TextFormField(
                          key: const Key('form-description-es'),
                          controller: _descriptionEs,
                          minLines: 3,
                          maxLines: 8,
                          decoration: InputDecoration(
                            labelText: _copy.descriptionSpanish,
                          ),
                          validator: _required,
                        ),
                        second: TextFormField(
                          key: const Key('form-description-va'),
                          controller: _descriptionVa,
                          minLines: 3,
                          maxLines: 8,
                          decoration: InputDecoration(
                            labelText: _copy.descriptionValencian,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _DeadlineField(
                        copy: _copy,
                        deadline: _deadline,
                        errorText: _deadlineError,
                        onChoose: saving ? null : _chooseDeadline,
                        onClear: saving || _deadline == null
                            ? null
                            : () => setState(() {
                                _deadline = null;
                                _deadlineError = null;
                              }),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        _copy.fieldsTitle,
                        style: context.text.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      for (var index = 0; index < _fields.length; index++) ...[
                        _FieldEditor(
                          key: ValueKey(_fields[index]),
                          copy: _copy,
                          number: index + 1,
                          controllers: _fields[index],
                          canRemove: _fields.length > 1 && !saving,
                          canMoveUp: index > 0 && !saving,
                          canMoveDown: index < _fields.length - 1 && !saving,
                          onRemove: () => _removeField(index),
                          onMoveUp: () => _moveField(index, index - 1),
                          onMoveDown: () => _moveField(index, index + 1),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      OutlinedButton.icon(
                        key: const Key('add-form-field'),
                        onPressed: saving ? null : _addField,
                        icon: const Icon(Icons.add),
                        label: Text(_copy.addField),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          OutlinedButton(
                            onPressed: saving ? null : widget.onCancel,
                            child: Text(_copy.cancel),
                          ),
                          FilledButton.icon(
                            key: const Key('save-form'),
                            onPressed: saving
                                ? null
                                : () => _submit(municipalityId),
                            icon: saving
                                ? const SizedBox.square(
                                    dimension: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_copy.save),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
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

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? _copy.requiredField : null;

  void _addField() => setState(() => _fields.add(_FieldControllers()));

  void _removeField(int index) {
    final removed = _fields.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _moveField(int from, int to) => setState(() {
    final field = _fields.removeAt(from);
    _fields.insert(to, field);
  });

  Future<void> _chooseDeadline() async {
    final now = DateTime.now();
    final initial = _deadline ?? now.add(const Duration(days: 7));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    setState(() {
      _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _deadlineError = null;
    });
  }

  Future<void> _submit(String municipalityId) async {
    final valid = _formKey.currentState?.validate() ?? false;
    final keys = _fields.map((field) => field.key.text.trim()).toList();
    if (keys.toSet().length != keys.length) {
      _showMessage(_copy.duplicateFieldKeys);
      return;
    }
    if (_deadline != null && !_deadline!.isAfter(DateTime.now())) {
      setState(() => _deadlineError = _copy.futureDeadline);
      return;
    }
    if (!valid) return;

    final failure = await ref
        .read(formEditorViewModelProvider.notifier)
        .create(
          CreateFormInput(
            municipalityId: municipalityId,
            title: FormLocalizedText(
              es: _titleEs.text,
              va: _optional(_titleVa.text),
            ),
            description: FormLocalizedText(
              es: _descriptionEs.text,
              va: _optional(_descriptionVa.text),
            ),
            deadline: _deadline,
            fields: _fields
                .map(
                  (field) => FormFieldDraft(
                    key: field.key.text,
                    label: FormLocalizedText(
                      es: field.labelEs.text,
                      va: _optional(field.labelVa.text),
                    ),
                    type: field.type,
                    required: field.required,
                    options: field.options.text
                        .split(RegExp(r'[\n,]'))
                        .map((option) => option.trim())
                        .where((option) => option.isNotEmpty)
                        .toList(growable: false),
                  ),
                )
                .toList(growable: false),
          ),
        );
    if (!mounted) return;
    if (failure != null) {
      _showMessage(_failureText(failure));
      return;
    }
    _showMessage(_copy.created);
    widget.onCreated();
  }

  String? _optional(String value) => value.trim().isEmpty ? null : value.trim();

  String _failureText(AppFailure failure) {
    if (failure is NetworkFailure) return _copy.networkError;
    if (failure is ValidationFailure) {
      return switch (failure.message) {
        'form_duplicate_keys' => _copy.duplicateFieldKeys,
        'form_future_deadline' => _copy.futureDeadline,
        _ => _copy.genericError,
      };
    }
    return _copy.genericError;
  }

  void _showMessage(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.copy, required this.onBack});
  final FormsCopy copy;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: onBack,
        tooltip: copy.cancel,
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Text(copy.createTitle, style: context.text.headlineLarge),
      ),
    ],
  );
}

class _LocalizedPair extends StatelessWidget {
  const _LocalizedPair({required this.first, required this.second});
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

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({
    required this.copy,
    required this.deadline,
    required this.onChoose,
    required this.onClear,
    this.errorText,
  });
  final FormsCopy copy;
  final DateTime? deadline;
  final VoidCallback? onChoose;
  final VoidCallback? onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: copy.optionalDeadline,
        errorText: errorText,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            deadline == null
                ? copy.noDeadline
                : DateFormat.yMMMd(locale).add_Hm().format(deadline!),
          ),
          OutlinedButton.icon(
            onPressed: onChoose,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(copy.chooseDeadline),
          ),
          if (deadline != null)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: Text(copy.clearDeadline),
            ),
        ],
      ),
    );
  }
}

class _FieldEditor extends StatefulWidget {
  const _FieldEditor({
    required this.copy,
    required this.number,
    required this.controllers,
    required this.canRemove,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
    super.key,
  });
  final FormsCopy copy;
  final int number;
  final _FieldControllers controllers;
  final bool canRemove;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onRemove;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;

  @override
  State<_FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<_FieldEditor> {
  @override
  Widget build(BuildContext context) {
    final field = widget.controllers;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.copy.fieldNumber(widget.number),
                    style: context.text.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: widget.canMoveUp ? widget.onMoveUp : null,
                  tooltip: widget.copy.moveFieldUp,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: widget.canMoveDown ? widget.onMoveDown : null,
                  tooltip: widget.copy.moveFieldDown,
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  onPressed: widget.canRemove ? widget.onRemove : null,
                  tooltip: widget.copy.removeField,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              key: Key('form-field-key-${widget.number}'),
              controller: field.key,
              decoration: InputDecoration(
                labelText: widget.copy.fieldKey,
                helperText: widget.copy.fieldKeyHint,
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return widget.copy.requiredField;
                return RegExp(r'^[a-z0-9_]+$').hasMatch(trimmed)
                    ? null
                    : widget.copy.invalidFieldKey;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _LocalizedPair(
              first: TextFormField(
                key: Key('form-field-label-es-${widget.number}'),
                controller: field.labelEs,
                decoration: InputDecoration(
                  labelText: widget.copy.fieldLabelSpanish,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? widget.copy.requiredField
                    : null,
              ),
              second: TextFormField(
                key: Key('form-field-label-va-${widget.number}'),
                controller: field.labelVa,
                decoration: InputDecoration(
                  labelText: widget.copy.fieldLabelValencian,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<ManagedFormFieldType>(
              initialValue: field.type,
              isExpanded: true,
              decoration: InputDecoration(labelText: widget.copy.fieldType),
              items: ManagedFormFieldType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        _typeLabel(widget.copy, type),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() {
                field.type = value ?? ManagedFormFieldType.text;
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: field.required,
              onChanged: (value) => setState(() => field.required = value),
              title: Text(widget.copy.fieldRequired),
            ),
            if (field.type == ManagedFormFieldType.select) ...[
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                key: Key('form-field-options-${widget.number}'),
                controller: field.options,
                minLines: 3,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: widget.copy.fieldOptions,
                  helperText: widget.copy.fieldOptionsHint,
                ),
                validator: (value) {
                  final options = (value ?? '')
                      .split(RegExp(r'[\n,]'))
                      .map((option) => option.trim())
                      .where((option) => option.isNotEmpty)
                      .toSet();
                  return options.length < 2
                      ? widget.copy.selectNeedsOptions
                      : null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _typeLabel(FormsCopy copy, ManagedFormFieldType type) => switch (type) {
  ManagedFormFieldType.text => copy.fieldTypeText,
  ManagedFormFieldType.number => copy.fieldTypeNumber,
  ManagedFormFieldType.select => copy.fieldTypeSelect,
  ManagedFormFieldType.date => copy.fieldTypeDate,
  ManagedFormFieldType.boolean => copy.fieldTypeBoolean,
};

class _FieldControllers {
  final key = TextEditingController();
  final labelEs = TextEditingController();
  final labelVa = TextEditingController();
  final options = TextEditingController();
  ManagedFormFieldType type = ManagedFormFieldType.text;
  bool required = false;

  void dispose() {
    key.dispose();
    labelEs.dispose();
    labelVa.dispose();
    options.dispose();
  }
}
