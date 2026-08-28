import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

const List<String> incidentCategorySlugs = <String>[
  'alumbrado',
  'baches',
  'limpieza',
  'jardines',
  'mobiliario',
  'agua',
  'otros',
];

String incidentCategoryLabel(AppLocalizations l10n, String slug) =>
    switch (slug) {
      'alumbrado' => l10n.incidentCategoryAlumbrado,
      'baches' => l10n.incidentCategoryBaches,
      'limpieza' => l10n.incidentCategoryLimpieza,
      'jardines' => l10n.incidentCategoryJardines,
      'mobiliario' => l10n.incidentCategoryMobiliario,
      'agua' => l10n.incidentCategoryAgua,
      _ => l10n.incidentCategoryOtros,
    };

/// A visible, tappable list rather than a dropdown: every option stays on
/// screen at once, which reads better with TalkBack/VoiceOver than a closed
/// menu (A-25) and each row already clears the 48dp touch target.
class IncidentCategoryField extends StatelessWidget {
  const IncidentCategoryField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Card(
      child: RadioGroup<String>(
        groupValue: value,
        onChanged: (String? selected) {
          if (selected != null) onChanged(selected);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final String slug in incidentCategorySlugs)
              RadioListTile<String>(
                value: slug,
                title: Text(incidentCategoryLabel(l10n, slug)),
              ),
          ],
        ),
      ),
    );
  }
}
