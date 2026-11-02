import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/l10n/app_locales.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/domain/value_objects/localized_text.dart';
import '../../domain/entities/form.dart';

/// Dispatches on [FormFieldDefinition.type] — the generic engine the PRD
/// asks for: no per-form hardcoded widget, one renderer that reads whatever
/// shape the backoffice configured.
class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({
    required this.field,
    required this.value,
    required this.locale,
    required this.onChanged,
    this.showRequiredError = false,
    super.key,
  });

  final FormFieldDefinition field;
  final String? value;
  final AppLocale locale;
  final ValueChanged<String> onChanged;

  /// True once the vecino has tried to submit with this required field
  /// still empty — surfaces the error on the field itself instead of
  /// only disabling the submit button with no explanation (A-21).
  final bool showRequiredError;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ResolvedLocalizedText label = field.label.resolve(locale);
    final String labelText = field.required
        ? '${label.text} (${l10n.formRequiredLabel})'
        : label.text;
    final bool isMissing =
        showRequiredError &&
        field.required &&
        (value == null || value!.trim().isEmpty);
    final String? errorText = isMissing ? l10n.formFieldRequiredError : null;

    return switch (field.type) {
      FormFieldType.boolean => _BooleanField(
        label: labelText,
        value: value,
        onChanged: onChanged,
        errorText: errorText,
      ),
      FormFieldType.select => _SelectField(
        label: labelText,
        options: field.options,
        value: value,
        onChanged: onChanged,
        errorText: errorText,
      ),
      FormFieldType.date => _DateField(
        label: labelText,
        value: value,
        onChanged: onChanged,
        errorText: errorText,
      ),
      FormFieldType.number => _TextField(
        label: labelText,
        value: value,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        errorText: errorText,
      ),
      FormFieldType.text => _TextField(
        label: labelText,
        value: value,
        keyboardType: TextInputType.text,
        onChanged: onChanged,
        errorText: errorText,
      ),
    };
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.value,
    required this.keyboardType,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextFormField(
        initialValue: value,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _BooleanField extends StatelessWidget {
  const _BooleanField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        shape: errorText == null
            ? null
            : RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
        child: RadioGroup<String>(
          groupValue: value,
          onChanged: (String? selected) {
            if (selected != null) onChanged(selected);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(label),
                ),
              ),
              RadioListTile<String>(
                value: 'true',
                title: Text(l10n.formBooleanYes),
              ),
              RadioListTile<String>(
                value: 'false',
                title: Text(l10n.formBooleanNo),
              ),
              if (errorText != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
        hint: Text(l10n.formSelectPlaceholder),
        items: <DropdownMenuItem<String>>[
          for (final String option in options)
            DropdownMenuItem<String>(
              value: option,
              child: Text(option, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (String? selected) {
          if (selected != null) onChanged(selected);
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime? selected = value == null ? null : DateTime.tryParse(value!);
    final String display = selected == null
        ? l10n.formPickDate
        : DateFormat.yMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(selected);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton.icon(
            style: errorText == null
                ? null
                : OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selected ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 3650)),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (picked != null) {
                onChanged(picked.toIso8601String());
              }
            },
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(display),
          ),
          if (errorText != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
