import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Display for a field whose value is picked through `showDatePicker` /
/// `showTimePicker` rather than typed.
///
/// Every backoffice editor that needs "pick an optional or required date
/// (and time)" used to carry its own copy of this layout — one per feature,
/// each with a slightly different detail (an icon-only button here, a
/// labelled one there). That drift is how a genuinely free-text field like
/// opening hours once grew a hand-typed `HH:mm` box instead of a picker.
/// This widget is the single shape every editor should reach for instead.
class AppDateTimeField extends StatelessWidget {
  const AppDateTimeField({
    required this.label,
    required this.valueLabel,
    required this.chooseLabel,
    required this.onChoose,
    this.clearLabel,
    this.onClear,
    this.errorText,
    super.key,
  });

  /// The field's own label, shown by the surrounding [InputDecorator].
  final String label;

  /// The current value, already formatted for display (or a placeholder
  /// such as "No deadline" when nothing is picked yet).
  final String valueLabel;

  final String chooseLabel;
  final VoidCallback? onChoose;

  /// Non-null shows a "clear" action; null hides it entirely (for a
  /// required field, or an optional one with nothing picked yet).
  final String? clearLabel;
  final VoidCallback? onClear;

  final String? errorText;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label, errorText: errorText),
    child: Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(valueLabel),
        OutlinedButton.icon(
          onPressed: onChoose,
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(chooseLabel),
        ),
        if (clearLabel != null)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            label: Text(clearLabel!),
          ),
      ],
    ),
  );
}
