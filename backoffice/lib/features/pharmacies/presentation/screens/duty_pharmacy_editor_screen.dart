import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/manager_profile.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/duty_pharmacy.dart';
import '../viewmodels/duty_pharmacy_editor_view_model.dart';

class DutyPharmacyEditorScreen extends ConsumerStatefulWidget {
  const DutyPharmacyEditorScreen({
    super.key,
    this.municipalityId,
    this.date,
    this.initial,
  });

  final String? municipalityId;
  final DateTime? date;
  final DutyPharmacy? initial;

  bool get isEditing => municipalityId != null && date != null;

  @override
  ConsumerState<DutyPharmacyEditorScreen> createState() =>
      _DutyPharmacyEditorScreenState();
}

class _DutyPharmacyEditorScreenState
    extends ConsumerState<DutyPharmacyEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pharmacyName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _schedule = TextEditingController();
  final _municipalityIds = <String>{};
  late DateTime _date;
  bool _hydrated = false;
  String? _municipalitiesError;

  @override
  void initState() {
    super.initState();
    _date = _dateOnly(widget.date ?? DateTime.now());
    final selectedMunicipality = ref.read(selectedMunicipalityProvider);
    _municipalityIds.add(widget.municipalityId ?? selectedMunicipality.id);
    if (widget.initial case final initial?) {
      _hydrate(initial);
    }
    if (widget.isEditing) {
      Future<void>.microtask(
        () => ref
            .read(dutyPharmacyEditorViewModelProvider.notifier)
            .load(
              municipalityId: widget.municipalityId!,
              date: widget.date!,
              initial: widget.initial,
            ),
      );
    }
  }

  @override
  void dispose() {
    _pharmacyName.dispose();
    _address.dispose();
    _phone.dispose();
    _schedule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final municipalities = ref.watch(
      authViewModelProvider.select(
        (auth) =>
            auth.valueOrNull?.municipalities ?? const <ManagedMunicipality>[],
      ),
    );
    final editor = ref.watch(dutyPharmacyEditorViewModelProvider);
    ref.listen(
      dutyPharmacyEditorViewModelProvider.select(
        (value) => value.valueOrNull?.pharmacy,
      ),
      (_, pharmacy) {
        if (pharmacy != null) _hydrate(pharmacy);
      },
    );

    if (widget.isEditing && editor.hasError) {
      return _EditorError(
        error: editor.error!,
        onRetry: () => ref
            .read(dutyPharmacyEditorViewModelProvider.notifier)
            .load(
              municipalityId: widget.municipalityId!,
              date: widget.date!,
              initial: widget.initial,
            ),
      );
    }
    if (widget.isEditing && editor.isLoading && !_hydrated) {
      return Semantics(
        liveRegion: true,
        label: l10n.loading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EditorHeader(isEditing: widget.isEditing),
                  const SizedBox(height: AppSpacing.xl),
                  _DateField(
                    date: _date,
                    enabled: !widget.isEditing && !editor.isLoading,
                    onPressed: _pickDate,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _AdaptiveFields(
                    first: TextFormField(
                      key: const Key('duty-pharmacy-name'),
                      controller: _pharmacyName,
                      enabled: !editor.isLoading,
                      maxLength: 200,
                      decoration: InputDecoration(
                        labelText: l10n.dutyPharmacyNameLabel,
                      ),
                      validator: _requiredValidator,
                    ),
                    second: TextFormField(
                      key: const Key('duty-pharmacy-address'),
                      controller: _address,
                      enabled: !editor.isLoading,
                      maxLength: 300,
                      decoration: InputDecoration(
                        labelText: l10n.dutyPharmacyAddressLabel,
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _AdaptiveFields(
                    first: TextFormField(
                      key: const Key('duty-pharmacy-phone'),
                      controller: _phone,
                      enabled: !editor.isLoading,
                      maxLength: 50,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.dutyPharmacyPhoneLabel,
                      ),
                      validator: _requiredValidator,
                    ),
                    second: TextFormField(
                      key: const Key('duty-pharmacy-schedule'),
                      controller: _schedule,
                      enabled: !editor.isLoading,
                      maxLength: 100,
                      decoration: InputDecoration(
                        labelText: l10n.dutyPharmacyScheduleLabel,
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (widget.isEditing)
                    _FixedMunicipality(
                      municipality: municipalities.firstWhere(
                        (value) => value.id == widget.municipalityId,
                        orElse: () => ManagedMunicipality(
                          id: widget.municipalityId!,
                          name: widget.municipalityId!,
                          province: '',
                          languages: const [],
                        ),
                      ),
                    )
                  else
                    _MunicipalityChoices(
                      municipalities: municipalities,
                      selectedIds: _municipalityIds,
                      errorText: _municipalitiesError,
                      enabled: !editor.isLoading,
                      onChanged: (id, selected) => setState(() {
                        selected
                            ? _municipalityIds.add(id)
                            : _municipalityIds.remove(id);
                        _municipalitiesError = null;
                      }),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        OutlinedButton(
                          onPressed: editor.isLoading
                              ? null
                              : () => context.go('/farmacias'),
                          child: Text(l10n.cancel),
                        ),
                        FilledButton.icon(
                          onPressed: editor.isLoading ? null : _submit,
                          icon: editor.isLoading
                              ? const SizedBox.square(
                                  dimension: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(l10n.saveDutyPharmacy),
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

  void _hydrate(DutyPharmacy pharmacy) {
    if (_hydrated) return;
    _pharmacyName.text = pharmacy.pharmacyName;
    _address.text = pharmacy.address;
    _phone.text = pharmacy.phone;
    _schedule.text = pharmacy.schedule;
    _date = _dateOnly(pharmacy.date);
    _municipalityIds
      ..clear()
      ..add(pharmacy.municipalityId);
    _hydrated = true;
    if (mounted) setState(() {});
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: AppLocalizations.of(context).selectDutyPharmacyDate,
    );
    if (selected != null && mounted) {
      setState(() => _date = _dateOnly(selected));
    }
  }

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty
      ? AppLocalizations.of(context).requiredField
      : null;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (_municipalityIds.isEmpty) {
      setState(() => _municipalitiesError = l10n.requiredField);
    }
    if (!formValid || _municipalityIds.isEmpty) return;

    final failure = await ref
        .read(dutyPharmacyEditorViewModelProvider.notifier)
        .save(
          SaveDutyPharmacyInput(
            date: _date,
            pharmacyName: _pharmacyName.text,
            address: _address.text,
            phone: _phone.text,
            schedule: _schedule.text,
            municipalityIds: _municipalityIds.toList(growable: false),
            replaceExisting: widget.isEditing,
          ),
        );
    if (!mounted) return;
    if (failure != null) {
      final message = switch (failure) {
        ConflictFailure(message: 'duty_pharmacy_date_exists') =>
          l10n.dutyPharmacyDateExists,
        NetworkFailure() => l10n.networkError,
        _ => l10n.genericError,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.dutyPharmacySavedMessage)));
    context.go('/farmacias');
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
          onPressed: () => context.go('/farmacias'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isEditing
                ? l10n.dutyPharmacyEditorEditTitle
                : l10n.dutyPharmacyEditorNewTitle,
            style: context.text.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.enabled,
    required this.onPressed,
  });

  final DateTime date;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.dutyPharmacyDateLabel),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          Text(
            DateFormat.yMMMMEEEEd(locale).format(date),
            style: context.text.bodyLarge,
          ),
          if (enabled)
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(l10n.selectDutyPharmacyDate),
            ),
        ],
      ),
    );
  }
}

class _AdaptiveFields extends StatelessWidget {
  const _AdaptiveFields({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= 760) {
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

class _MunicipalityChoices extends StatelessWidget {
  const _MunicipalityChoices({
    required this.municipalities,
    required this.selectedIds,
    required this.onChanged,
    required this.enabled,
    this.errorText,
  });

  final List<ManagedMunicipality> municipalities;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.publishMunicipalities,
        errorText: errorText,
      ),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xs,
        children: municipalities
            .map(
              (municipality) => FilterChip(
                label: Text(municipality.name),
                selected: selectedIds.contains(municipality.id),
                onSelected: enabled
                    ? (value) => onChanged(municipality.id, value)
                    : null,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _FixedMunicipality extends StatelessWidget {
  const _FixedMunicipality({required this.municipality});

  final ManagedMunicipality municipality;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InputDecorator(
      decoration: InputDecoration(labelText: l10n.municipalityLabel),
      child: Text(municipality.name),
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

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
