import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/text/optional_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_alert.dart';
import '../../domain/usecases/alert_usecases.dart';
import '../viewmodels/alert_editor_view_model.dart';
import '../viewmodels/alerts_view_model.dart';

class AlertEditorScreen extends ConsumerStatefulWidget {
  const AlertEditorScreen({this.alertId, this.initialAlert, super.key});

  final String? alertId;
  final ManagedAlert? initialAlert;

  @override
  ConsumerState<AlertEditorScreen> createState() => _AlertEditorScreenState();
}

class _AlertEditorScreenState extends ConsumerState<AlertEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phenomenon = TextEditingController();
  final _bodyEs = TextEditingController();
  final _bodyVa = TextEditingController();

  ManagedAlertSeverity _severity = ManagedAlertSeverity.yellow;
  // Meteorológico por defecto, no incendio: la prioridad de incendio/
  // evacuación se consigue con el ORDEN del selector, no con marcarlo
  // seleccionado de partida (un gestor no debe publicar un incendio sin
  // querer por no haber tocado el campo).
  ManagedAlertPhenomenonType _phenomenonType =
      ManagedAlertPhenomenonType.meteorologico;
  late DateTime _startAt;
  late final String _municipalityId;
  late final String _municipalityName;
  DateTime? _endAt;
  bool _hydrated = false;

  bool get _isEditing => widget.alertId != null;

  @override
  void initState() {
    super.initState();
    _startAt = DateTime.now();
    final municipality = ref.read(selectedMunicipalityProvider);
    _municipalityId = municipality.id;
    _municipalityName = municipality.name;
    final id = widget.alertId;
    if (id != null) {
      Future<void>.microtask(() {
        if (!mounted) return;
        ref
            .read(alertEditorViewModelProvider.notifier)
            .load(
              id: id,
              municipalityId: _municipalityId,
              initial: widget.initialAlert,
            );
      });
    }
  }

  @override
  void dispose() {
    _phenomenon.dispose();
    _bodyEs.dispose();
    _bodyVa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editor = ref.watch(alertEditorViewModelProvider);
    final item = editor.valueOrNull?.item;
    if (item != null && !_hydrated) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate(item));
    }

    if (_isEditing && editor.isLoading && !_hydrated) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: l10n.loading,
          child: const CircularProgressIndicator(),
        ),
      );
    }
    if (editor.hasError && !_hydrated) {
      return _EditorError(
        error: editor.error!,
        onRetry: () => ref
            .read(alertEditorViewModelProvider.notifier)
            .load(
              id: widget.alertId!,
              municipalityId: _municipalityId,
              initial: widget.initialAlert,
            ),
      );
    }
    if (item != null && !item.canManage) {
      return _AemetReadOnlyState();
    }

    final busy = editor.isLoading;
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EditorHeader(isEditing: _isEditing),
                  const SizedBox(height: AppSpacing.xl),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.municipalityLabel,
                    ),
                    child: Text(_municipalityName),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _phenomenon,
                    decoration: InputDecoration(
                      labelText: l10n.alertPhenomenonLabel,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l10n.requiredField
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.alertPhenomenonTypeField,
                    style: context.text.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _PhenomenonTypeChoices(
                    value: _phenomenonType,
                    onChanged: busy
                        ? null
                        : (value) => setState(() => _phenomenonType = value),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.alertSeverityField, style: context.text.titleLarge),
                  const SizedBox(height: AppSpacing.sm),
                  _SeverityChoices(
                    value: _severity,
                    onChanged: busy
                        ? null
                        : (value) => setState(() => _severity = value),
                  ),
                  if (_severity == ManagedAlertSeverity.red) ...[
                    const SizedBox(height: AppSpacing.md),
                    _RedNotificationNotice(),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _LanguageFields(bodyEs: _bodyEs, bodyVa: _bodyVa),
                  const SizedBox(height: AppSpacing.xl),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final start = AppDateTimeField(
                        label: l10n.alertStartField,
                        valueLabel: _formatDateTime(context, _startAt),
                        chooseLabel: l10n.chooseDateTime,
                        onChoose: busy ? null : _selectStart,
                      );
                      final end = AppDateTimeField(
                        label: l10n.alertEndField,
                        valueLabel: _endAt == null
                            ? l10n.alertWithoutEnd
                            : _formatDateTime(context, _endAt!),
                        chooseLabel: l10n.chooseDateTime,
                        onChoose: busy ? null : _selectEnd,
                        clearLabel: _endAt == null ? null : l10n.clearAlertEnd,
                        onClear: _endAt == null || busy
                            ? null
                            : () => setState(() => _endAt = null),
                      );
                      if (constraints.maxWidth >= 760) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: start),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: end),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          start,
                          const SizedBox(height: AppSpacing.md),
                          end,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        OutlinedButton(
                          onPressed: busy ? null : () => context.go('/alertas'),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton.icon(
                          onPressed: busy ? null : _submit,
                          icon: busy
                              ? const SizedBox.square(
                                  dimension: AppSize.iconMd,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : Icon(
                                  _isEditing
                                      ? Icons.save_outlined
                                      : Icons.notification_add_outlined,
                                ),
                          label: Text(
                            _isEditing ? l10n.saveChanges : l10n.publishAlert,
                          ),
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

  void _hydrate(ManagedAlert item) {
    if (!mounted || _hydrated) return;
    _phenomenon.text = item.phenomenon;
    _bodyEs.text = item.body.es;
    _bodyVa.text = item.body.va ?? '';
    _severity = item.severity;
    _phenomenonType = item.phenomenonType;
    _startAt = item.startAt.toLocal();
    _endAt = item.endAt?.toLocal();
    setState(() => _hydrated = true);
  }

  Future<void> _selectStart() async {
    final value = await _pickDateTime(_startAt);
    if (value == null || !mounted) return;
    setState(() => _startAt = value);
  }

  Future<void> _selectEnd() async {
    final value = await _pickDateTime(_endAt ?? _startAt);
    if (value == null || !mounted) return;
    setState(() => _endAt = value);
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_endAt case final end? when end.isBefore(_startAt)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.alertEndBeforeStart)));
      return;
    }
    final failure = await ref
        .read(alertEditorViewModelProvider.notifier)
        .save(
          SaveManualAlertInput(
            id: widget.alertId,
            municipalityId: _municipalityId,
            severity: _severity,
            phenomenonType: _phenomenonType,
            phenomenon: _phenomenon.text,
            body: AlertLocalizedText(
              es: _bodyEs.text,
              va: optionalText(_bodyVa.text),
            ),
            startAt: _startAt,
            endAt: _endAt,
          ),
        );
    if (!mounted) return;
    if (failure != null) {
      final message = switch (failure.message) {
        SaveManualAlert.endBeforeStartCode => l10n.alertEndBeforeStart,
        _ when failure is NetworkFailure => l10n.networkError,
        _ => l10n.genericError,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ref.invalidate(alertsViewModelProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? l10n.savedMessage : l10n.alertPublishedMessage,
        ),
      ),
    );
    context.go('/alertas');
  }

  String _formatDateTime(BuildContext context, DateTime value) =>
      DateFormat.yMd(
        Localizations.localeOf(context).toLanguageTag(),
      ).add_Hm().format(value);
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: () => context.go('/alertas'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isEditing ? l10n.alertEditorEditTitle : l10n.alertEditorNewTitle,
            style: context.text.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _LanguageFields extends StatelessWidget {
  const _LanguageFields({required this.bodyEs, required this.bodyVa});

  final TextEditingController bodyEs;
  final TextEditingController bodyVa;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spanish = TextFormField(
      controller: bodyEs,
      minLines: 6,
      maxLines: 12,
      decoration: InputDecoration(
        labelText: l10n.alertBodySpanish,
        alignLabelWithHint: true,
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? l10n.requiredField : null,
    );
    final valencian = TextFormField(
      controller: bodyVa,
      minLines: 6,
      maxLines: 12,
      decoration: InputDecoration(
        labelText: l10n.alertBodyValencian,
        alignLabelWithHint: true,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: spanish),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: valencian),
            ],
          );
        }
        return Column(
          children: [
            spanish,
            const SizedBox(height: AppSpacing.md),
            valencian,
          ],
        );
      },
    );
  }
}

class _SeverityChoices extends StatelessWidget {
  const _SeverityChoices({required this.value, required this.onChanged});

  final ManagedAlertSeverity value;
  final ValueChanged<ManagedAlertSeverity>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ManagedAlertSeverity.values
          .map(
            (severity) => _SeverityChoice(
              severity: severity,
              label: switch (severity) {
                ManagedAlertSeverity.yellow => l10n.alertSeverityYellow,
                ManagedAlertSeverity.orange => l10n.alertSeverityOrange,
                ManagedAlertSeverity.red => l10n.alertSeverityRed,
              },
              selected: severity == value,
              onPressed: onChanged == null ? null : () => onChanged!(severity),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _SeverityChoice extends StatelessWidget {
  const _SeverityChoice({
    required this.severity,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final ManagedAlertSeverity severity;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final visualSeverity = switch (severity) {
      ManagedAlertSeverity.yellow => AlertSeverity.yellow,
      ManagedAlertSeverity.orange => AlertSeverity.orange,
      ManagedAlertSeverity.red => AlertSeverity.red,
    };
    final colors = context.semantic.of(visualSeverity);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSize.minTouchTarget),
        child: Material(
          color: selected ? colors.identity : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xsAll,
            side: BorderSide(
              color: colors.border,
              width: selected
                  ? AppSize.borderWidth
                  : AppSize.severityChipBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.xsAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(switch (severity) {
                    ManagedAlertSeverity.yellow => Icons.warning_amber_rounded,
                    ManagedAlertSeverity.orange => Icons.report_problem_rounded,
                    ManagedAlertSeverity.red => Icons.emergency_rounded,
                  }, color: selected ? colors.onIdentity : colors.heading),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      style: context.text.labelLarge?.copyWith(
                        color: selected ? colors.onIdentity : colors.heading,
                      ),
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
}

/// Calcado de [_SeverityChoices]/[_SeverityChoice], pero para el tipo de
/// fenómeno: lista EXPLÍCITA (no `.values` a secas) para que un reordenado
/// futuro del enum no pueda enterrar incendio/evacuación sin que se note en
/// el diff. Colores neutros del tema, nunca de severidad — un chip de
/// categoría no puede confundirse visualmente con uno de severidad.
class _PhenomenonTypeChoices extends StatelessWidget {
  const _PhenomenonTypeChoices({required this.value, required this.onChanged});

  final ManagedAlertPhenomenonType value;
  final ValueChanged<ManagedAlertPhenomenonType>? onChanged;

  static const List<ManagedAlertPhenomenonType> _orderedTypes =
      <ManagedAlertPhenomenonType>[
        ManagedAlertPhenomenonType.incendio,
        ManagedAlertPhenomenonType.evacuacion,
        ManagedAlertPhenomenonType.sanitario,
        ManagedAlertPhenomenonType.meteorologico,
        ManagedAlertPhenomenonType.otro,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _orderedTypes
          .map(
            (type) => _PhenomenonTypeChoice(
              type: type,
              label: switch (type) {
                ManagedAlertPhenomenonType.incendio =>
                  l10n.alertPhenomenonTypeIncendio,
                ManagedAlertPhenomenonType.evacuacion =>
                  l10n.alertPhenomenonTypeEvacuacion,
                ManagedAlertPhenomenonType.sanitario =>
                  l10n.alertPhenomenonTypeSanitario,
                ManagedAlertPhenomenonType.meteorologico =>
                  l10n.alertPhenomenonTypeMeteorologico,
                ManagedAlertPhenomenonType.otro => l10n.alertPhenomenonTypeOtro,
              },
              selected: type == value,
              onPressed: onChanged == null ? null : () => onChanged!(type),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _PhenomenonTypeChoice extends StatelessWidget {
  const _PhenomenonTypeChoice({
    required this.type,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final ManagedAlertPhenomenonType type;
  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final graphic = context.semantic.brandGraphic;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSize.minTouchTarget),
        child: Material(
          color: selected
              ? graphic.withValues(alpha: 0.12)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.xsAll,
            side: BorderSide(
              color: selected ? graphic : outline,
              width: selected
                  ? AppSize.borderWidth
                  : AppSize.severityChipBorderWidth,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.xsAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(switch (type) {
                    ManagedAlertPhenomenonType.incendio =>
                      Icons.local_fire_department,
                    ManagedAlertPhenomenonType.evacuacion =>
                      Icons.directions_run,
                    ManagedAlertPhenomenonType.sanitario =>
                      Icons.medical_services_outlined,
                    ManagedAlertPhenomenonType.meteorologico =>
                      Icons.cloud_outlined,
                    ManagedAlertPhenomenonType.otro => Icons.category_outlined,
                  }, color: selected ? graphic : outline),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      style: context.text.labelLarge?.copyWith(
                        color: selected ? graphic : outline,
                      ),
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
}

class _RedNotificationNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.semantic.alertRed;
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: AppRadius.smAll,
        ),
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notification_important, color: colors.heading),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.alertRedPushWarning,
                  style: context.text.bodyLarge?.copyWith(
                    color: colors.onSurface,
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

class _AemetReadOnlyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.maxContentWidth),
          child: Semantics(
            liveRegion: true,
            child: Column(
              children: [
                const AppIconBadge(
                  icon: Icons.cloud_outlined,
                  size: AppIconBadgeSize.large,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.alertAemetReadOnly, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => context.go('/alertas'),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorError extends StatelessWidget {
  const _EditorError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error is NetworkFailure ? l10n.networkError : l10n.genericError,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
