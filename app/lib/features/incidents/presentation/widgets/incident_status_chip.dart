import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/incident.dart';

class IncidentStatusChip extends StatelessWidget {
  const IncidentStatusChip({required this.status, super.key});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String label = switch (status) {
      IncidentStatus.received => l10n.incidentStatusReceived,
      IncidentStatus.inProgress => l10n.incidentStatusInProgress,
      IncidentStatus.resolved => l10n.incidentStatusResolved,
    };
    final ColorScheme colors = Theme.of(context).colorScheme;
    final (Color background, Color foreground) = switch (status) {
      IncidentStatus.received => (
        colors.surfaceContainerHighest,
        colors.onSurface,
      ),
      IncidentStatus.inProgress => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      IncidentStatus.resolved => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };
    return Chip(
      backgroundColor: background,
      side: BorderSide.none,
      label: Text(label, style: TextStyle(color: foreground)),
    );
  }
}
