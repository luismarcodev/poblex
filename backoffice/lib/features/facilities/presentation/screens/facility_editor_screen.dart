import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_facility.dart';
import '../viewmodels/facility_editor_view_model.dart';

final RegExp _timeRegex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

class _DayHoursRow {
  _DayHoursRow({required this.closed, required String open, required String close})
    : open = TextEditingController(text: open),
      close = TextEditingController(text: close);

  bool closed;
  final TextEditingController open;
  final TextEditingController close;

  void dispose() {
    open.dispose();
    close.dispose();
  }
}

class FacilityEditorScreen extends ConsumerStatefulWidget {
  const FacilityEditorScreen({this.facilityId, this.initialFacility, super.key});

  final String? facilityId;
  final ManagedFacility? initialFacility;

  @override
  ConsumerState<FacilityEditorScreen> createState() =>
      _FacilityEditorScreenState();
}

class _FacilityEditorScreenState extends ConsumerState<FacilityEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEs = TextEditingController();
  final _nameVa = TextEditingController();
  final _category = TextEditingController();
  final _descriptionEs = TextEditingController();
  final _descriptionVa = TextEditingController();
  final _feeNoteEs = TextEditingController();
  final _feeNoteVa = TextEditingController();
  final _slotDuration = TextEditingController(text: '60');
  final _maxAdvanceDays = TextEditingController(text: '14');
  bool _active = true;
  late final Map<String, _DayHoursRow> _hours = {
    for (final day in facilityDayKeys)
      day: _DayHoursRow(
        closed: day == 'sun',
        open: '09:00',
        close: '22:00',
      ),
  };
  bool _hydrated = false;
  bool _saving = false;

  bool get _isEditing => widget.facilityId != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFacility;
    if (initial != null) {
      _hydrate(initial);
    } else {
      _hydrated = true;
    }
  }

  @override
  void dispose() {
    _nameEs.dispose();
    _nameVa.dispose();
    _category.dispose();
    _descriptionEs.dispose();
    _descriptionVa.dispose();
    _feeNoteEs.dispose();
    _feeNoteVa.dispose();
    _slotDuration.dispose();
    _maxAdvanceDays.dispose();
    for (final row in _hours.values) {
      row.dispose();
    }
    super.dispose();
  }

  void _hydrate(ManagedFacility facility) {
    _nameEs.text = facility.name.es;
    _nameVa.text = facility.name.va ?? '';
    _category.text = facility.category;
    _descriptionEs.text = facility.description?.es ?? '';
    _descriptionVa.text = facility.description?.va ?? '';
    _feeNoteEs.text = facility.feeNote?.es ?? '';
    _feeNoteVa.text = facility.feeNote?.va ?? '';
    _slotDuration.text = facility.slotDurationMinutes.toString();
    _maxAdvanceDays.text = facility.maxAdvanceBookingDays.toString();
    _active = facility.active;
    for (final day in facilityDayKeys) {
      final range = facility.openingHours[day];
      _hours[day]!.closed = range == null;
      if (range != null) {
        _hours[day]!.open.text = range.open;
        _hours[day]!.close.text = range.close;
      }
    }
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (!_hydrated) {
      return Semantics(
        liveRegion: true,
        label: l10n.loading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSize.maxWorkspaceWidth,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: [
                _EditorHeader(isEditing: _isEditing),
                const SizedBox(height: AppSpacing.xl),
                TextFormField(
                  controller: _nameEs,
                  decoration: InputDecoration(labelText: l10n.facilityNameEsLabel),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameVa,
                  decoration: InputDecoration(labelText: l10n.facilityNameVaLabel),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _category,
                  decoration: InputDecoration(
                    labelText: l10n.facilityCategoryLabel,
                    hintText: l10n.facilityCategoryHint,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.facilityDescriptionEsLabel, style: context.text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(controller: _descriptionEs, minLines: 2, maxLines: 4),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.facilityDescriptionVaLabel, style: context.text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(controller: _descriptionVa, minLines: 2, maxLines: 4),
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final left = TextFormField(
                      controller: _slotDuration,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.facilitySlotDurationFieldLabel,
                      ),
                      validator: _positiveIntValidator(l10n, max: 480),
                    );
                    final right = TextFormField(
                      controller: _maxAdvanceDays,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.facilityMaxAdvanceDaysLabel,
                      ),
                      validator: _positiveIntValidator(l10n, max: null),
                    );
                    if (constraints.maxWidth >= 620) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: right),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: AppSpacing.md),
                        right,
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.facilityOpeningHoursSectionTitle, style: context.text.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.facilityOpeningHoursSectionHelp, style: context.text.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                _OpeningHoursEditor(rows: _hours),
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.facilityFeeNoteEsLabel, style: context.text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _feeNoteEs,
                  decoration: InputDecoration(hintText: l10n.facilityFeeNoteHint),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.facilityFeeNoteVaLabel, style: context.text.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(controller: _feeNoteVa),
                if (_isEditing) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.facilityActiveSwitchLabel),
                    value: _active,
                    onChanged: (value) => setState(() => _active = value),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                InputDecorator(
                  decoration: InputDecoration(labelText: l10n.municipalityLabel),
                  child: Text(
                    ref.watch(selectedMunicipalityProvider).name,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => context.go('/instalaciones'),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton.icon(
                        onPressed: _saving ? null : _submit,
                        icon: _saving
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              )
                            : Icon(
                                _isEditing
                                    ? Icons.save_outlined
                                    : Icons.add_business_outlined,
                              ),
                        label: Text(_isEditing ? l10n.saveChanges : l10n.newFacility),
                      ),
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

  String? Function(String?) _positiveIntValidator(
    AppLocalizations l10n, {
    required int? max,
  }) {
    return (value) {
      final parsed = int.tryParse(value?.trim() ?? '');
      if (parsed == null || parsed <= 0) return l10n.invalidNumber;
      if (max != null && parsed > max) return l10n.invalidNumber;
      return null;
    };
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    final hoursValid = _validateHours(l10n);
    if (!formValid || !hoursValid) {
      if (!hoursValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.facilityInvalidHours)),
        );
      }
      return;
    }

    setState(() => _saving = true);
    final municipalityId = ref.read(selectedMunicipalityProvider).id;
    final openingHours = {
      for (final day in facilityDayKeys)
        day: _hours[day]!.closed
            ? null
            : FacilityDayHours(
                open: _hours[day]!.open.text.trim(),
                close: _hours[day]!.close.text.trim(),
              ),
    };

    final failure = await ref
        .read(facilityEditorViewModelProvider.notifier)
        .save(
          SaveFacilityInput(
            id: widget.facilityId,
            municipalityId: municipalityId,
            name: FacilityLocalizedText(
              es: _nameEs.text.trim(),
              va: _optional(_nameVa.text),
            ),
            description: _descriptionEs.text.trim().isEmpty
                ? null
                : FacilityLocalizedText(
                    es: _descriptionEs.text.trim(),
                    va: _optional(_descriptionVa.text),
                  ),
            category: _category.text.trim(),
            slotDurationMinutes: int.parse(_slotDuration.text.trim()),
            openingHours: openingHours,
            feeNote: _feeNoteEs.text.trim().isEmpty
                ? null
                : FacilityLocalizedText(
                    es: _feeNoteEs.text.trim(),
                    va: _optional(_feeNoteVa.text),
                  ),
            maxAdvanceBookingDays: int.parse(_maxAdvanceDays.text.trim()),
            active: _active,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure is NetworkFailure ? l10n.networkError : l10n.genericError,
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? l10n.facilitySavedMessage : l10n.facilityCreatedMessage,
        ),
      ),
    );
    context.go('/instalaciones');
  }

  bool _validateHours(AppLocalizations l10n) {
    for (final row in _hours.values) {
      if (row.closed) continue;
      final open = row.open.text.trim();
      final close = row.close.text.trim();
      if (!_timeRegex.hasMatch(open) ||
          !_timeRegex.hasMatch(close) ||
          open.compareTo(close) >= 0) {
        return false;
      }
    }
    return true;
  }
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
          onPressed: () => context.go('/instalaciones'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isEditing ? l10n.editorEditFacilityTitle : l10n.editorNewFacilityTitle,
            style: context.text.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _OpeningHoursEditor extends StatefulWidget {
  const _OpeningHoursEditor({required this.rows});
  final Map<String, _DayHoursRow> rows;

  @override
  State<_OpeningHoursEditor> createState() => _OpeningHoursEditorState();
}

class _OpeningHoursEditorState extends State<_OpeningHoursEditor> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            for (final day in facilityDayKeys)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final row = widget.rows[day]!;
                    final dayLabel = SizedBox(
                      width: 120,
                      child: Text(_dayLabel(l10n, day)),
                    );
                    final closedSwitch = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: !row.closed,
                          onChanged: (value) =>
                              setState(() => row.closed = !value),
                        ),
                        Text(
                          row.closed
                              ? l10n.facilityClosedLabel
                              : l10n.facilityOpenLabel,
                        ),
                      ],
                    );
                    final times = row.closed
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: row.open,
                                  decoration: InputDecoration(
                                    labelText: l10n.facilityOpenTimeLabel,
                                    hintText: '09:00',
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: TextField(
                                  controller: row.close,
                                  decoration: InputDecoration(
                                    labelText: l10n.facilityCloseTimeLabel,
                                    hintText: '22:00',
                                  ),
                                ),
                              ),
                            ],
                          );
                    if (constraints.maxWidth >= 560) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          dayLabel,
                          closedSwitch,
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: times),
                        ],
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [dayLabel, closedSwitch]),
                        if (!row.closed) ...[
                          const SizedBox(height: AppSpacing.xs),
                          times,
                        ],
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(AppLocalizations l10n, String day) => switch (day) {
    'mon' => l10n.facilityDayMon,
    'tue' => l10n.facilityDayTue,
    'wed' => l10n.facilityDayWed,
    'thu' => l10n.facilityDayThu,
    'fri' => l10n.facilityDayFri,
    'sat' => l10n.facilityDaySat,
    _ => l10n.facilityDaySun,
  };
}
