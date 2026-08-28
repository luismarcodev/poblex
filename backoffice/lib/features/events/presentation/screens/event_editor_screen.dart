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
import '../../domain/entities/managed_event.dart';
import '../../domain/value_objects/event_category.dart';
import '../viewmodels/event_editor_view_model.dart';

class EventEditorScreen extends ConsumerStatefulWidget {
  const EventEditorScreen({this.eventId, this.initialEvent, super.key});

  final String? eventId;
  final ManagedEvent? initialEvent;

  @override
  ConsumerState<EventEditorScreen> createState() => _EventEditorScreenState();
}

class _EventEditorScreenState extends ConsumerState<EventEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEs = TextEditingController();
  final _titleVa = TextEditingController();
  final _descriptionEs = TextEditingController();
  final _descriptionVa = TextEditingController();
  final _category = TextEditingController();
  final _location = TextEditingController();
  final _latitude = TextEditingController();
  final _longitude = TextEditingController();
  final _municipalityIds = <String>{};
  late DateTime _startAt;
  DateTime? _endAt;
  bool _hydrated = false;
  String? _municipalitiesError;
  String? _datesError;

  bool get _isEditing => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startAt = DateTime(now.year, now.month, now.day + 1, 10);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final municipalityId = ref.read(selectedMunicipalityProvider).id;
      if (_isEditing) {
        ref
            .read(eventEditorViewModelProvider.notifier)
            .load(
              id: widget.eventId!,
              municipalityId: municipalityId,
              initial: widget.initialEvent,
            );
      } else {
        _municipalityIds.add(municipalityId);
        setState(() => _hydrated = true);
      }
    });
  }

  @override
  void dispose() {
    _titleEs.dispose();
    _titleVa.dispose();
    _descriptionEs.dispose();
    _descriptionVa.dispose();
    _category.dispose();
    _location.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editor = ref.watch(eventEditorViewModelProvider);
    final event = editor.valueOrNull?.event;
    if (_isEditing && !_hydrated && event != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate(event));
    }

    if (editor.hasError && event == null) {
      return _EditorError(
        error: editor.error!,
        onRetry: () => ref
            .read(eventEditorViewModelProvider.notifier)
            .load(
              id: widget.eventId!,
              municipalityId: ref.read(selectedMunicipalityProvider).id,
            ),
      );
    }
    if (!_hydrated || (editor.isLoading && event == null)) {
      return Semantics(
        liveRegion: true,
        label: l10n.loading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = ref.watch(
      authViewModelProvider.select((auth) => auth.valueOrNull),
    );
    if (profile == null) {
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
                _LanguageFields(
                  titleEs: _titleEs,
                  titleVa: _titleVa,
                  descriptionEs: _descriptionEs,
                  descriptionVa: _descriptionVa,
                ),
                const SizedBox(height: AppSpacing.xl),
                _AdaptiveFields(
                  first: TextFormField(
                    key: const Key('event-category'),
                    controller: _category,
                    decoration: InputDecoration(
                      labelText: l10n.categoryLabel,
                      hintText: l10n.categoryHint,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.requiredField;
                      }
                      return isValidEventCategory(value)
                          ? null
                          : l10n.invalidCategory;
                    },
                  ),
                  second: TextFormField(
                    key: const Key('event-location'),
                    controller: _location,
                    decoration: InputDecoration(
                      labelText: l10n.eventLocationLabel,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _DateFields(
                  startAt: _startAt,
                  endAt: _endAt,
                  errorText: _datesError,
                  onPickStart: () => _pickDateTime(_startAt, (value) {
                    setState(() {
                      _startAt = value;
                      _datesError = null;
                    });
                  }),
                  onPickEnd: () => _pickDateTime(
                    _endAt ?? _startAt.add(const Duration(hours: 1)),
                    (value) => setState(() {
                      _endAt = value;
                      _datesError = null;
                    }),
                  ),
                  onClearEnd: _endAt == null
                      ? null
                      : () => setState(() {
                          _endAt = null;
                          _datesError = null;
                        }),
                ),
                const SizedBox(height: AppSpacing.xl),
                _AdaptiveFields(
                  first: TextFormField(
                    key: const Key('event-latitude'),
                    controller: _latitude,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.eventLatitudeLabel,
                    ),
                    validator: _validateLatitude,
                  ),
                  second: TextFormField(
                    key: const Key('event-longitude'),
                    controller: _longitude,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.eventLongitudeLabel,
                    ),
                    validator: _validateLongitude,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_isEditing)
                  _FixedMunicipality(
                    municipality: profile.municipalities.firstWhere(
                      (value) => value.id == event!.municipalityId,
                    ),
                  )
                else
                  _MunicipalityChoices(
                    municipalities: profile.municipalities,
                    selectedIds: _municipalityIds,
                    errorText: _municipalitiesError,
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
                            : () => context.go('/eventos'),
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
                            : Icon(
                                _isEditing
                                    ? Icons.save_outlined
                                    : Icons.publish,
                              ),
                        label: Text(
                          _isEditing ? l10n.saveChanges : l10n.publishEvent,
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
    );
  }

  void _hydrate(ManagedEvent event) {
    if (!mounted || _hydrated) return;
    _titleEs.text = event.title.es;
    _titleVa.text = event.title.va ?? '';
    _descriptionEs.text = event.description.es;
    _descriptionVa.text = event.description.va ?? '';
    _category.text = event.category;
    _location.text = event.locationName ?? '';
    _latitude.text = event.latitude?.toString() ?? '';
    _longitude.text = event.longitude?.toString() ?? '';
    _municipalityIds.add(event.municipalityId);
    _startAt = event.startAt.toLocal();
    _endAt = event.endAt?.toLocal();
    setState(() => _hydrated = true);
  }

  Future<void> _pickDateTime(
    DateTime initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  String? _validateLatitude(String? value) {
    final l10n = AppLocalizations.of(context);
    final latitudeText = value?.trim() ?? '';
    final longitudeText = _longitude.text.trim();
    if (latitudeText.isEmpty != longitudeText.isEmpty) {
      return l10n.eventCoordinatePairRequired;
    }
    if (latitudeText.isEmpty) return null;
    final latitude = _parseCoordinate(latitudeText);
    return latitude == null || latitude < -90 || latitude > 90
        ? l10n.invalidLatitude
        : null;
  }

  String? _validateLongitude(String? value) {
    final l10n = AppLocalizations.of(context);
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final longitude = _parseCoordinate(text);
    return longitude == null || longitude < -180 || longitude > 180
        ? l10n.invalidLongitude
        : null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    final datesValid = _endAt == null || !_endAt!.isBefore(_startAt);
    if (!datesValid) setState(() => _datesError = l10n.eventEndBeforeStart);
    if (_municipalityIds.isEmpty) {
      setState(() => _municipalitiesError = l10n.requiredField);
    }
    if (!formValid || !datesValid || _municipalityIds.isEmpty) return;

    final failure = await ref
        .read(eventEditorViewModelProvider.notifier)
        .save(
          SaveEventInput(
            id: widget.eventId,
            title: EventLocalizedText(
              es: _titleEs.text,
              va: _optional(_titleVa.text),
            ),
            description: EventLocalizedText(
              es: _descriptionEs.text,
              va: _optional(_descriptionVa.text),
            ),
            startAt: _startAt,
            endAt: _endAt,
            locationName: _optional(_location.text),
            latitude: _parseCoordinate(_latitude.text),
            longitude: _parseCoordinate(_longitude.text),
            category: _category.text.trim(),
            municipalityIds: _municipalityIds.toList(growable: false),
          ),
        );
    if (!mounted) return;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_failureMessage(l10n, failure))));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? l10n.savedMessage : l10n.eventPublishedMessage,
        ),
      ),
    );
    context.go('/eventos');
  }

  String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseCoordinate(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  String _failureMessage(AppLocalizations l10n, AppFailure failure) {
    if (failure is NetworkFailure) return l10n.networkError;
    if (failure is ValidationFailure) {
      return switch (failure.message) {
        'event_end_before_start' => l10n.eventEndBeforeStart,
        'event_coordinate_pair_required' => l10n.eventCoordinatePairRequired,
        _ => l10n.genericError,
      };
    }
    return l10n.genericError;
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
          onPressed: () => context.go('/eventos'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isEditing ? l10n.eventEditorEditTitle : l10n.eventEditorNewTitle,
            style: context.text.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _LanguageFields extends StatelessWidget {
  const _LanguageFields({
    required this.titleEs,
    required this.titleVa,
    required this.descriptionEs,
    required this.descriptionVa,
  });

  final TextEditingController titleEs;
  final TextEditingController titleVa;
  final TextEditingController descriptionEs;
  final TextEditingController descriptionVa;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final spanish = _LanguageColumn(
          titleKey: const Key('event-title-es'),
          descriptionKey: const Key('event-description-es'),
          title: titleEs,
          description: descriptionEs,
          titleLabel: l10n.titleSpanish,
          descriptionLabel: l10n.eventDescriptionSpanish,
          requiredMessage: l10n.requiredField,
          required: true,
        );
        final valencian = _LanguageColumn(
          titleKey: const Key('event-title-va'),
          descriptionKey: const Key('event-description-va'),
          title: titleVa,
          description: descriptionVa,
          titleLabel: l10n.titleValencian,
          descriptionLabel: l10n.eventDescriptionValencian,
          requiredMessage: l10n.requiredField,
          required: false,
        );
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

class _LanguageColumn extends StatelessWidget {
  const _LanguageColumn({
    required this.titleKey,
    required this.descriptionKey,
    required this.title,
    required this.description,
    required this.titleLabel,
    required this.descriptionLabel,
    required this.requiredMessage,
    required this.required,
  });

  final Key titleKey;
  final Key descriptionKey;
  final TextEditingController title;
  final TextEditingController description;
  final String titleLabel;
  final String descriptionLabel;
  final String requiredMessage;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        key: titleKey,
        controller: title,
        decoration: InputDecoration(labelText: titleLabel),
        validator: required ? _requiredValidator : null,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        key: descriptionKey,
        controller: description,
        minLines: 5,
        maxLines: 12,
        decoration: InputDecoration(
          labelText: descriptionLabel,
          alignLabelWithHint: true,
        ),
        validator: required ? _requiredValidator : null,
      ),
    ],
  );

  String? _requiredValidator(String? value) =>
      value == null || value.trim().isEmpty ? requiredMessage : null;
}

class _AdaptiveFields extends StatelessWidget {
  const _AdaptiveFields({required this.first, required this.second});

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

class _DateFields extends StatelessWidget {
  const _DateFields({
    required this.startAt,
    required this.endAt,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onClearEnd,
    this.errorText,
  });

  final DateTime startAt;
  final DateTime? endAt;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback? onClearEnd;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final format = DateFormat.yMMMd(locale).add_Hm();
    return InputDecorator(
      decoration: InputDecoration(errorText: errorText),
      child: _AdaptiveFields(
        first: _DateSelector(
          label: l10n.eventStartLabel,
          value: format.format(startAt),
          onPressed: onPickStart,
          actionLabel: l10n.eventChangeDate,
        ),
        second: _DateSelector(
          label: l10n.eventEndLabel,
          value: endAt == null ? null : format.format(endAt!),
          onPressed: onPickEnd,
          actionLabel: endAt == null
              ? l10n.eventSetEndDate
              : l10n.eventChangeDate,
          onClear: onClearEnd,
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.label,
    required this.value,
    required this.onPressed,
    required this.actionLabel,
    this.onClear,
  });

  final String label;
  final String? value;
  final VoidCallback onPressed;
  final String actionLabel;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.text.labelLarge),
        if (value != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(value!, style: context.text.bodyLarge),
        ],
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(actionLabel),
            ),
            if (onClear != null)
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.clear),
                label: Text(l10n.eventRemoveEndDate),
              ),
          ],
        ),
      ],
    );
  }
}

class _MunicipalityChoices extends StatelessWidget {
  const _MunicipalityChoices({
    required this.municipalities,
    required this.selectedIds,
    required this.onChanged,
    this.errorText,
  });

  final List<ManagedMunicipality> municipalities;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onChanged;
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
                onSelected: (value) => onChanged(municipality.id, value),
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
