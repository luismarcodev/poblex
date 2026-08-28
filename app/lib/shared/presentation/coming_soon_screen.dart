import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../l10n/app_localizations.dart';
import 'app_drawer.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({required this.section, super.key});
  final String section;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String title = switch (section) {
      'events' => l10n.sectionEvents,
      'alerts' => l10n.sectionAlerts,
      'incidents' => l10n.sectionIncidents,
      'surveys' => l10n.sectionSurveys,
      'forms' => l10n.sectionForms,
      'pharmacies' => l10n.sectionPharmacies,
      _ => l10n.appName,
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const AppIconBadge(
                        icon: Icons.construction,
                        size: AppIconBadgeSize.large,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.comingSoonTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(l10n.comingSoonBody, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
