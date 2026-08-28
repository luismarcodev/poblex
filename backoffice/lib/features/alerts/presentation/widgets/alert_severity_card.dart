import 'package:flutter/material.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../domain/entities/managed_alert.dart';

class AlertSeverityCard extends StatelessWidget {
  const AlertSeverityCard({
    required this.alert,
    required this.severityLabel,
    required this.phenomenonTypeLabel,
    required this.sourceLabel,
    required this.statusLabel,
    required this.body,
    required this.startLabel,
    required this.endLabel,
    required this.semanticsLabel,
    required this.editLabel,
    required this.deleteLabel,
    required this.busy,
    this.createdByLabel,
    this.updatedByLabel,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  final ManagedAlert alert;
  final String severityLabel;
  final String phenomenonTypeLabel;
  final String sourceLabel;
  final String statusLabel;
  final String body;
  final String startLabel;
  final String endLabel;
  final String semanticsLabel;
  final String editLabel;
  final String deleteLabel;
  final String? createdByLabel;
  final String? updatedByLabel;
  final bool busy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final visualSeverity = _visualSeverity(alert.severity);
    final severityColors = context.semantic.of(visualSeverity);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: semanticsLabel,
        child: ClipRRect(
          borderRadius: AppRadius.smAll,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: severityColors.surface,
              border: Border(
                left: BorderSide(
                  color: severityColors.bar,
                  width: visualSeverity.barWidth,
                ),
                top: BorderSide(color: severityColors.border),
                right: BorderSide(color: severityColors.border),
                bottom: BorderSide(color: severityColors.border),
              ),
            ),
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SeverityBadge(
                        severity: alert.severity,
                        label: severityLabel,
                        colors: severityColors,
                      ),
                      Chip(label: Text(sourceLabel)),
                      Chip(label: Text(phenomenonTypeLabel)),
                      Text(
                        statusLabel,
                        style: context.text.labelLarge?.copyWith(
                          color: severityColors.heading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    alert.phenomenon,
                    style: context.text.titleLarge?.copyWith(
                      color: severityColors.heading,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: context.text.bodyLarge?.copyWith(
                      color: severityColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    startLabel,
                    style: context.text.bodyMedium?.copyWith(
                      color: severityColors.onSurface,
                    ),
                  ),
                  Text(
                    endLabel,
                    style: context.text.bodyMedium?.copyWith(
                      color: severityColors.onSurface,
                    ),
                  ),
                  if (createdByLabel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(createdByLabel!),
                  ],
                  if (updatedByLabel != null) Text(updatedByLabel!),
                  if (alert.canManage) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        OutlinedButton.icon(
                          onPressed: busy ? null : onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(editLabel),
                        ),
                        TextButton.icon(
                          onPressed: busy ? null : onDelete,
                          icon: busy
                              ? const SizedBox.square(
                                  dimension: AppSize.iconMd,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.delete_outline),
                          label: Text(deleteLabel),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({
    required this.severity,
    required this.label,
    required this.colors,
  });

  final ManagedAlertSeverity severity;
  final String label;
  final SeverityColors colors;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: colors.identity,
      border: Border.all(
        color: colors.border,
        width: AppSize.severityChipBorderWidth,
      ),
      borderRadius: AppRadius.xsAll,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _severityIcon(severity),
            color: colors.onIdentity,
            size: AppSize.iconMd,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: colors.onIdentity,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

AlertSeverity _visualSeverity(ManagedAlertSeverity severity) =>
    switch (severity) {
      ManagedAlertSeverity.yellow => AlertSeverity.yellow,
      ManagedAlertSeverity.orange => AlertSeverity.orange,
      ManagedAlertSeverity.red => AlertSeverity.red,
    };

IconData _severityIcon(ManagedAlertSeverity severity) => switch (severity) {
  ManagedAlertSeverity.yellow => Icons.warning_amber_rounded,
  ManagedAlertSeverity.orange => Icons.report_problem_rounded,
  ManagedAlertSeverity.red => Icons.emergency_rounded,
};
