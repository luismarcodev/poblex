import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/presentation/failure_view.dart';
import '../../domain/entities/incident.dart';
import '../viewmodels/incident_report_view_model.dart';
import '../viewmodels/my_incidents_view_model.dart';
import '../widgets/incident_category_field.dart';

class IncidentReportScreen extends ConsumerStatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  ConsumerState<IncidentReportScreen> createState() =>
      _IncidentReportScreenState();
}

class _IncidentReportScreenState extends ConsumerState<IncidentReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<IncidentReportUiState> report = ref.watch(
      incidentReportViewModelProvider,
    );
    final notifier = ref.read(incidentReportViewModelProvider.notifier);

    ref.listen<AsyncValue<IncidentReportUiState>>(
      incidentReportViewModelProvider,
      (
        AsyncValue<IncidentReportUiState>? previous,
        AsyncValue<IncidentReportUiState> next,
      ) {
        final Incident? submitted = next.value?.submitted;
        if (submitted != null && previous?.value?.submitted == null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.incidentSubmitted)));
          // La incidencia recién creada tiene que verse en "Mis incidencias"
          // sin que el vecino tenga que hacer pull-to-refresh a mano.
          ref.invalidate(myIncidentsViewModelProvider);
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/incidents');
          }
        }
      },
    );

    final IncidentReportUiState state =
        report.value ?? const IncidentReportUiState();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.incidentReportTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSize.maxContentWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.incidentCategoryLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                IncidentCategoryField(
                  value: state.category,
                  onChanged: notifier.setCategory,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.incidentDescriptionLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 2000,
                  decoration: InputDecoration(
                    hintText: l10n.incidentDescriptionHint,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: notifier.setDescription,
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.photoBytes != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: AppRadius.lgAll,
                        child: Image.memory(
                          state.photoBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: notifier.clearPhoto,
                        icon: const Icon(Icons.close),
                        tooltip: l10n.incidentPhotoRemove,
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => _pickPhoto(context, notifier),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: Text(l10n.incidentPhotoAdd),
                  ),
                const SizedBox(height: AppSpacing.xl),
                if (state.failure != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InlineFailureView(
                      failure: state.failure!,
                      sectionName: l10n.sectionIncidents,
                      onRetry: notifier.submit,
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: AppSize.comfortableTouchTarget,
                  child: FilledButton(
                    onPressed: state.canSubmit ? notifier.submit : null,
                    child: state.submitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.incidentSubmit),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(
    BuildContext context,
    IncidentReportViewModel notifier,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.incidentPhotoSourceCamera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.incidentPhotoSourceGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final Uint8List bytes = await picked.readAsBytes();
    notifier.setPhoto(bytes, picked.name);
  }
}
