import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/text/optional_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../domain/entities/managed_business.dart';
import '../../domain/usecases/business_usecases.dart';
import '../platform/business_photo_picker.dart';
import '../viewmodels/business_categories_provider.dart';
import '../viewmodels/business_editor_view_model.dart';

typedef BusinessPhotoPicker = Future<List<PickedBusinessPhoto>> Function();

class BusinessEditorScreen extends ConsumerStatefulWidget {
  const BusinessEditorScreen({
    this.businessId,
    this.initialBusiness,
    this.photoPicker,
    super.key,
  });

  final String? businessId;
  final ManagedBusiness? initialBusiness;
  final BusinessPhotoPicker? photoPicker;

  @override
  ConsumerState<BusinessEditorScreen> createState() =>
      _BusinessEditorScreenState();
}

class _BusinessEditorScreenState extends ConsumerState<BusinessEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _descriptionEs = TextEditingController();
  final _descriptionVa = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  final _schedule = TextEditingController();
  bool _hydrated = false;
  int _photoUploadCurrent = 0;
  int _photoUploadTotal = 0;

  bool get _isEditing => widget.businessId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isEditing) {
        ref
            .read(businessEditorViewModelProvider.notifier)
            .load(widget.businessId!, initial: widget.initialBusiness);
      } else {
        setState(() => _hydrated = true);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _descriptionEs.dispose();
    _descriptionVa.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    _schedule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editor = ref.watch(businessEditorViewModelProvider);
    final business = editor.valueOrNull?.business;
    final uploadingPhoto = editor.valueOrNull?.uploadingPhoto ?? false;
    final editorBusy = editor.isLoading || uploadingPhoto;
    if (_isEditing && !_hydrated && business != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate(business));
    }

    if (editor.hasError && business == null) {
      return _EditorError(
        error: editor.error!,
        onRetry: () => ref
            .read(businessEditorViewModelProvider.notifier)
            .load(widget.businessId!),
      );
    }
    if (!_hydrated || (editor.isLoading && business == null)) {
      return Semantics(
        liveRegion: true,
        label: l10n.loading,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = ref.watch(
      authViewModelProvider.select((auth) => auth.valueOrNull),
    );
    if (profile == null) return const SizedBox.shrink();
    final municipalityId =
        business?.municipalityId ?? ref.watch(selectedMunicipalityProvider).id;
    final municipality = profile.municipalities.firstWhere(
      (value) => value.id == municipalityId,
    );

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
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: l10n.businessNameLabel,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.requiredField
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoryField(
                  controller: _category,
                  municipalityId: municipalityId,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.businessDescriptionEsLabel,
                  style: context.text.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descriptionEs,
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.businessDescriptionVaLabel,
                  style: context.text.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descriptionVa,
                  minLines: 3,
                  maxLines: 6,
                ),
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final left = Column(
                      children: [
                        TextFormField(
                          controller: _address,
                          decoration: InputDecoration(
                            labelText: l10n.businessAddressLabel,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.businessPhoneLabel,
                          ),
                        ),
                      ],
                    );
                    final right = Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.businessEmailLabel,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return value.contains('@')
                                ? null
                                : l10n.invalidEmail;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _website,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            labelText: l10n.businessWebsiteLabel,
                          ),
                          validator: _optionalUrlValidator(l10n),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          controller: _schedule,
                          decoration: InputDecoration(
                            labelText: l10n.businessScheduleLabel,
                          ),
                        ),
                      ],
                    );
                    if (constraints.maxWidth >= 900) {
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
                _BusinessPhotosSection(
                  isEditing: _isEditing,
                  enabled: business != null && !editor.isLoading,
                  photos: business?.photos ?? const [],
                  uploading: uploadingPhoto,
                  uploadCurrent: _photoUploadCurrent,
                  uploadTotal: _photoUploadTotal,
                  failure: editor.valueOrNull?.photoFailure,
                  onAdd: _pickAndUploadPhotos,
                  onRetry: _retryPhoto,
                  onDelete: _deletePhoto,
                  onMove: _movePhoto,
                ),
                const SizedBox(height: AppSpacing.xl),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.municipalityLabel,
                  ),
                  child: Text(municipality.name),
                ),
                if (_isEditing) ...[
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.businessActiveSwitchLabel),
                    value: business!.active,
                    onChanged: (value) => ref
                        .read(businessEditorViewModelProvider.notifier)
                        .setActive(value),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      OutlinedButton(
                        onPressed: editorBusy
                            ? null
                            : () => context.go('/comercios'),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton.icon(
                        onPressed: editorBusy ? null : _submit,
                        icon: editorBusy
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : Icon(
                                _isEditing
                                    ? Icons.save_outlined
                                    : Icons.add_business_outlined,
                              ),
                        label: Text(
                          _isEditing ? l10n.saveChanges : l10n.newBusiness,
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

  String? Function(String?) _optionalUrlValidator(AppLocalizations l10n) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      final uri = Uri.tryParse(value.trim());
      return uri != null &&
              (uri.scheme == 'http' || uri.scheme == 'https') &&
              uri.host.isNotEmpty
          ? null
          : l10n.invalidUrl;
    };
  }

  void _hydrate(ManagedBusiness business) {
    if (!mounted || _hydrated) return;
    _name.text = business.name;
    _category.text = business.category;
    _descriptionEs.text = business.descriptionEs ?? '';
    _descriptionVa.text = business.descriptionVa ?? '';
    _address.text = business.address ?? '';
    _phone.text = business.phone ?? '';
    _email.text = business.email ?? '';
    _website.text = business.website ?? '';
    _schedule.text = business.schedule ?? '';
    setState(() => _hydrated = true);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    final municipalityId =
        widget.initialBusiness?.municipalityId ??
        ref.read(selectedMunicipalityProvider).id;

    final failure = await ref
        .read(businessEditorViewModelProvider.notifier)
        .save(
          SaveBusinessInput(
            id: widget.businessId,
            municipalityId: municipalityId,
            name: _name.text.trim(),
            category: _category.text.trim(),
            descriptionEs: optionalText(_descriptionEs.text),
            descriptionVa: optionalText(_descriptionVa.text),
            address: optionalText(_address.text),
            phone: optionalText(_phone.text),
            email: optionalText(_email.text),
            website: optionalText(_website.text),
            schedule: optionalText(_schedule.text),
          ),
        );
    if (!mounted) return;
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
          _isEditing ? l10n.businessSavedMessage : l10n.businessCreatedMessage,
        ),
      ),
    );
    context.go('/comercios');
  }

  Future<void> _pickAndUploadPhotos() async {
    List<PickedBusinessPhoto> picked;
    try {
      picked = await (widget.photoPicker ?? pickBusinessPhotos)();
    } catch (_) {
      if (mounted) {
        _showPhotoFailure(
          const ValidationFailure(message: UploadBusinessPhoto.invalidFileCode),
        );
      }
      return;
    }
    if (!mounted || picked.isEmpty) return;

    setState(() {
      _photoUploadTotal = picked.length;
      _photoUploadCurrent = 0;
    });
    for (final file in picked) {
      if (!mounted) return;
      setState(() => _photoUploadCurrent += 1);
      final failure = await ref
          .read(businessEditorViewModelProvider.notifier)
          .uploadPhoto(
            BusinessPhotoUploadFile(name: file.name, bytes: file.bytes),
          );
      if (!mounted) return;
      if (failure != null) {
        _showPhotoFailure(failure);
        setState(() {
          _photoUploadTotal = 0;
          _photoUploadCurrent = 0;
        });
        return;
      }
    }
    setState(() {
      _photoUploadTotal = 0;
      _photoUploadCurrent = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).businessPhotoUploadSuccess),
      ),
    );
  }

  Future<void> _retryPhoto() async {
    final failure = await ref
        .read(businessEditorViewModelProvider.notifier)
        .retryPhoto();
    if (!mounted || failure != null) {
      if (failure != null) _showPhotoFailure(failure);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).businessPhotoUploadSuccess),
      ),
    );
  }

  Future<void> _deletePhoto(String photoId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.businessPhotoDeleteTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final failure = await ref
        .read(businessEditorViewModelProvider.notifier)
        .deletePhoto(photoId);
    if (!mounted || failure == null) return;
    _showPhotoFailure(failure);
  }

  Future<void> _movePhoto(List<String> orderedPhotoIds) async {
    final failure = await ref
        .read(businessEditorViewModelProvider.notifier)
        .reorderPhotos(orderedPhotoIds);
    if (!mounted || failure == null) return;
    _showPhotoFailure(failure);
  }

  void _showPhotoFailure(AppFailure failure) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure.message) {
      UploadBusinessPhoto.tooLargeCode => l10n.businessPhotoTooLarge,
      UploadBusinessPhoto.unsupportedTypeCode =>
        l10n.businessPhotoUnsupportedType,
      UploadBusinessPhoto.invalidFileCode => l10n.businessPhotoInvalidFile,
      _ when failure is NetworkFailure => l10n.networkError,
      _ => l10n.businessPhotoUploadError,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          onPressed: () => context.go('/comercios'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isEditing
                ? l10n.editorEditBusinessTitle
                : l10n.editorNewBusinessTitle,
            style: context.text.headlineLarge,
          ),
        ),
      ],
    );
  }
}

class _CategoryField extends ConsumerWidget {
  const _CategoryField({
    required this.controller,
    required this.municipalityId,
  });
  final TextEditingController controller;
  final String municipalityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final categories = ref.watch(businessCategoriesProvider(municipalityId));
    final options = categories.valueOrNull ?? const <String>[];

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (value) {
        if (value.text.trim().isEmpty) return options;
        final query = value.text.trim().toLowerCase();
        return options.where((option) => option.toLowerCase().contains(query));
      },
      onSelected: (value) => controller.text = value,
      fieldViewBuilder: (context, fieldController, focusNode, onSubmit) {
        // Mantiene sincronizado el TextEditingController real del formulario
        // con el interno del Autocomplete, para que la validación e
        // hidratación del formulario sigan funcionando igual que un
        // TextFormField normal.
        fieldController.text = controller.text;
        fieldController.addListener(
          () => controller.text = fieldController.text,
        );
        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: l10n.businessCategoryLabel,
            hintText: l10n.businessCategoryHint,
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? l10n.requiredField : null,
        );
      },
    );
  }
}

class _BusinessPhotosSection extends StatelessWidget {
  const _BusinessPhotosSection({
    required this.isEditing,
    required this.enabled,
    required this.photos,
    required this.uploading,
    required this.uploadCurrent,
    required this.uploadTotal,
    required this.failure,
    required this.onAdd,
    required this.onRetry,
    required this.onDelete,
    required this.onMove,
  });

  final bool isEditing;
  final bool enabled;
  final List<BusinessPhoto> photos;
  final bool uploading;
  final int uploadCurrent;
  final int uploadTotal;
  final AppFailure? failure;
  final VoidCallback onAdd;
  final VoidCallback onRetry;
  final ValueChanged<String> onDelete;
  final ValueChanged<List<String>> onMove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sorted = photos.toList()
      ..sort((a, b) => a.position.compareTo(b.position));

    return Semantics(
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.businessPhotosTitle, style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.businessPhotosHelp, style: context.text.bodyMedium),
          if (!isEditing) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.businessPhotosPublishFirst),
          ],
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var index = 0; index < sorted.length; index++)
                  _PhotoThumbnail(
                    photo: sorted[index],
                    index: index,
                    total: sorted.length,
                    onDelete: () => onDelete(sorted[index].id),
                    onMoveLeft: index == 0
                        ? null
                        : () => onMove(_swapped(sorted, index, index - 1)),
                    onMoveRight: index == sorted.length - 1
                        ? null
                        : () => onMove(_swapped(sorted, index, index + 1)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (uploading)
            Semantics(
              liveRegion: true,
              label: l10n.businessPhotoUploading(uploadCurrent, uploadTotal),
              child: Row(
                children: [
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      l10n.businessPhotoUploading(uploadCurrent, uploadTotal),
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  onPressed: isEditing && enabled ? onAdd : null,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(l10n.businessPhotoAdd),
                ),
                if (failure != null)
                  FilledButton.tonalIcon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.businessPhotoRetry),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  List<String> _swapped(List<BusinessPhoto> ordered, int a, int b) {
    final ids = ordered.map((photo) => photo.id).toList();
    final temp = ids[a];
    ids[a] = ids[b];
    ids[b] = temp;
    return ids;
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.photo,
    required this.index,
    required this.total,
    required this.onDelete,
    required this.onMoveLeft,
    required this.onMoveRight,
  });

  final BusinessPhoto photo;
  final int index;
  final int total;
  final VoidCallback onDelete;
  final VoidCallback? onMoveLeft;
  final VoidCallback? onMoveRight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: CachedNetworkImage(
                imageUrl: photo.url,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const SizedBox(
                  width: 100,
                  height: 100,
                  child: Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Semantics(
                button: true,
                label: l10n.businessPhotoDeleteSemantic(index + 1),
                child: IconButton.filledTonal(
                  onPressed: onDelete,
                  icon: const Icon(Icons.close, size: 16),
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              label: l10n.businessPhotoMoveLeftSemantic(index + 1),
              child: IconButton(
                onPressed: onMoveLeft,
                icon: const Icon(Icons.arrow_back, size: 18),
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            Semantics(
              button: true,
              label: l10n.businessPhotoMoveRightSemantic(index + 1),
              child: IconButton(
                onPressed: onMoveRight,
                icon: const Icon(Icons.arrow_forward, size: 18),
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
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
