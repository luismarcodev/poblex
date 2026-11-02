import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/text/optional_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/viewmodels/auth_view_model.dart';
import '../../../auth/domain/entities/manager_profile.dart';
import '../../../auth/presentation/viewmodels/municipality_view_model.dart';
import '../../../social/presentation/viewmodels/social_connections_view_model.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/news_usecases.dart';
import '../../domain/value_objects/news_category.dart';
import '../platform/news_attachment_picker.dart';
import '../viewmodels/news_editor_view_model.dart';

typedef NewsAttachmentPicker = Future<PickedNewsAttachment?> Function();

class NewsEditorScreen extends ConsumerStatefulWidget {
  const NewsEditorScreen({
    this.newsId,
    this.initialNews,
    this.attachmentPicker,
    super.key,
  });

  final String? newsId;
  final NewsItem? initialNews;
  final NewsAttachmentPicker? attachmentPicker;

  @override
  ConsumerState<NewsEditorScreen> createState() => _NewsEditorScreenState();
}

class _NewsEditorScreenState extends ConsumerState<NewsEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEs = TextEditingController();
  final _titleVa = TextEditingController();
  final _bodyEs = TextEditingController();
  final _bodyVa = TextEditingController();
  final _category = TextEditingController();
  final _categoryFocusNode = FocusNode();
  final _imageUrl = TextEditingController();
  final _municipalityIds = <String>{};
  final _shareToChannels = <String>{};
  bool _pinned = false;
  bool _hydrated = false;
  String? _municipalitiesError;

  bool get _isEditing => widget.newsId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_isEditing) {
        ref
            .read(newsEditorViewModelProvider.notifier)
            .load(widget.newsId!, initial: widget.initialNews);
      } else {
        _municipalityIds.add(ref.read(selectedMunicipalityProvider).id);
        setState(() => _hydrated = true);
      }
    });
  }

  @override
  void dispose() {
    _titleEs.dispose();
    _titleVa.dispose();
    _bodyEs.dispose();
    _bodyVa.dispose();
    _category.dispose();
    _categoryFocusNode.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final editor = ref.watch(newsEditorViewModelProvider);
    final item = editor.valueOrNull?.item;
    final uploadingAttachment =
        editor.valueOrNull?.uploadingAttachment ?? false;
    final editorBusy = editor.isLoading || uploadingAttachment;
    if (_isEditing && !_hydrated && item != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate(item));
    }

    if (editor.hasError && item == null) {
      return _EditorError(
        error: editor.error!,
        onRetry: () =>
            ref.read(newsEditorViewModelProvider.notifier).load(widget.newsId!),
      );
    }
    if (!_hydrated || (editor.isLoading && item == null)) {
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
                  bodyEs: _bodyEs,
                  bodyVa: _bodyVa,
                ),
                const SizedBox(height: AppSpacing.xl),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final categorySuggestions =
                        ref
                            .watch(
                              newsCategoriesProvider(
                                ref.watch(selectedMunicipalityProvider).id,
                              ),
                            )
                            .valueOrNull ??
                        const <String>[];
                    final fields = [
                      Autocomplete<String>(
                        textEditingController: _category,
                        focusNode: _categoryFocusNode,
                        optionsBuilder: (value) {
                          if (value.text.trim().isEmpty) {
                            return categorySuggestions;
                          }
                          final query = value.text.trim().toLowerCase();
                          return categorySuggestions.where(
                            (option) => option.toLowerCase().contains(query),
                          );
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onSubmitted) =>
                                TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: l10n.categoryLabel,
                                    hintText: l10n.categoryHint,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.requiredField;
                                    }
                                    return isValidNewsCategory(value)
                                        ? null
                                        : l10n.invalidCategory;
                                  },
                                ),
                      ),
                      TextFormField(
                        controller: _imageUrl,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                          labelText: l10n.imageUrlLabel,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final uri = Uri.tryParse(value.trim());
                          return uri != null &&
                                  (uri.scheme == 'http' ||
                                      uri.scheme == 'https') &&
                                  uri.host.isNotEmpty
                              ? null
                              : l10n.invalidUrl;
                        },
                      ),
                    ];
                    if (constraints.maxWidth >= 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: fields.first),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: fields.last),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        fields.first,
                        const SizedBox(height: AppSpacing.md),
                        fields.last,
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _AttachmentsSection(
                  isEditing: _isEditing,
                  enabled: item != null && !editor.isLoading,
                  attachments: item?.attachments ?? const [],
                  uploading: uploadingAttachment,
                  failure: editor.valueOrNull?.attachmentFailure,
                  onAdd: _pickAndUploadAttachment,
                  onRetry: _retryAttachment,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_isEditing)
                  _FixedMunicipality(
                    municipality: profile.municipalities.firstWhere(
                      (value) => value.id == item!.municipalityId,
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
                if (!_isEditing) ...[
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.pinnedLabel),
                    value: _pinned,
                    onChanged: (value) => setState(() => _pinned = value),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ShareToChannels(
                    selected: _shareToChannels,
                    onChanged: (platform, selected) => setState(() {
                      selected
                          ? _shareToChannels.add(platform)
                          : _shareToChannels.remove(platform);
                    }),
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
                            : () => context.go('/noticias'),
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
                                    : Icons.publish,
                              ),
                        label: Text(
                          _isEditing ? l10n.saveChanges : l10n.publish,
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

  Future<void> _pickAndUploadAttachment() async {
    PickedNewsAttachment? picked;
    try {
      picked = await (widget.attachmentPicker ?? pickNewsAttachment)();
    } catch (_) {
      if (mounted) {
        _showAttachmentFailure(
          const ValidationFailure(
            message: UploadNewsAttachment.invalidFileCode,
          ),
        );
      }
      return;
    }
    if (!mounted || picked == null) return;
    final failure = await ref
        .read(newsEditorViewModelProvider.notifier)
        .uploadAttachment(
          NewsAttachmentUploadFile(name: picked.name, bytes: picked.bytes),
        );
    if (!mounted) return;
    if (failure != null) {
      _showAttachmentFailure(failure);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).newsAttachmentUploadSuccess),
      ),
    );
  }

  Future<void> _retryAttachment() async {
    final failure = await ref
        .read(newsEditorViewModelProvider.notifier)
        .retryAttachment();
    if (!mounted) return;
    if (failure != null) {
      _showAttachmentFailure(failure);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).newsAttachmentUploadSuccess),
      ),
    );
  }

  void _showAttachmentFailure(AppFailure failure) {
    final l10n = AppLocalizations.of(context);
    final message = switch (failure.message) {
      UploadNewsAttachment.tooLargeCode => l10n.newsAttachmentTooLarge,
      UploadNewsAttachment.unsupportedTypeCode =>
        l10n.newsAttachmentUnsupportedType,
      UploadNewsAttachment.invalidFileCode => l10n.newsAttachmentInvalidFile,
      _ when failure is NetworkFailure => l10n.networkError,
      _ => l10n.newsAttachmentUploadError,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _hydrate(NewsItem item) {
    if (!mounted || _hydrated) return;
    _titleEs.text = item.title.es;
    _titleVa.text = item.title.va ?? '';
    _bodyEs.text = item.body.es;
    _bodyVa.text = item.body.va ?? '';
    _category.text = item.category;
    _imageUrl.text = item.imageUrl ?? '';
    _municipalityIds.add(item.municipalityId);
    _pinned = item.pinned;
    setState(() => _hydrated = true);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    if (_municipalityIds.isEmpty) {
      setState(() => _municipalitiesError = l10n.requiredField);
    }
    if (!formValid || _municipalityIds.isEmpty) return;

    final failure = await ref
        .read(newsEditorViewModelProvider.notifier)
        .save(
          SaveNewsInput(
            id: widget.newsId,
            title: LocalizedText(
              es: _titleEs.text,
              va: optionalText(_titleVa.text),
            ),
            body: LocalizedText(
              es: _bodyEs.text,
              va: optionalText(_bodyVa.text),
            ),
            category: _category.text.trim(),
            imageUrl: optionalText(_imageUrl.text),
            pinned: _pinned,
            municipalityIds: _municipalityIds.toList(growable: false),
            shareToChannels: _shareToChannels,
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
        content: Text(_isEditing ? l10n.savedMessage : l10n.publishedMessage),
      ),
    );
    context.go('/noticias');
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
          onPressed: () => context.go('/noticias'),
          tooltip: l10n.cancel,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isEditing ? l10n.editorEditTitle : l10n.editorNewTitle,
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
    required this.bodyEs,
    required this.bodyVa,
  });
  final TextEditingController titleEs;
  final TextEditingController titleVa;
  final TextEditingController bodyEs;
  final TextEditingController bodyVa;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spanish = _LanguageColumn(
      title: titleEs,
      body: bodyEs,
      titleLabel: l10n.titleSpanish,
      bodyLabel: l10n.bodySpanish,
      requiredMessage: l10n.requiredField,
      required: true,
    );
    final valencian = _LanguageColumn(
      title: titleVa,
      body: bodyVa,
      titleLabel: l10n.titleValencian,
      bodyLabel: l10n.bodyValencian,
      requiredMessage: l10n.requiredField,
      required: false,
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

class _AttachmentsSection extends StatelessWidget {
  const _AttachmentsSection({
    required this.isEditing,
    required this.enabled,
    required this.attachments,
    required this.uploading,
    required this.failure,
    required this.onAdd,
    required this.onRetry,
  });

  final bool isEditing;
  final bool enabled;
  final List<NewsAttachment> attachments;
  final bool uploading;
  final AppFailure? failure;
  final VoidCallback onAdd;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      container: true,
      label: l10n.newsAttachmentCount(attachments.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.newsAttachmentsTitle, style: context.text.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.newsAttachmentsHelp, style: context.text.bodyMedium),
          if (!isEditing) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.newsAttachmentPublishFirst),
          ],
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...attachments.map(
              (attachment) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ExcludeSemantics(
                    child: Icon(
                      attachment.mimeType == 'application/pdf'
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                    ),
                  ),
                  title: Text(attachment.name),
                  subtitle: Text(attachment.mimeType),
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          if (uploading)
            Semantics(
              liveRegion: true,
              label: l10n.newsAttachmentUploading,
              child: Row(
                children: [
                  const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(child: Text(l10n.newsAttachmentUploading)),
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
                  icon: const Icon(Icons.attach_file),
                  label: Text(l10n.newsAttachmentAdd),
                ),
                if (failure != null)
                  FilledButton.tonalIcon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.newsAttachmentRetry),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LanguageColumn extends StatelessWidget {
  const _LanguageColumn({
    required this.title,
    required this.body,
    required this.titleLabel,
    required this.bodyLabel,
    required this.requiredMessage,
    required this.required,
  });
  final TextEditingController title;
  final TextEditingController body;
  final String titleLabel;
  final String bodyLabel;
  final String requiredMessage;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextFormField(
        controller: title,
        decoration: InputDecoration(labelText: titleLabel),
        validator: required
            ? (value) =>
                  value == null || value.trim().isEmpty ? requiredMessage : null
            : null,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: body,
        minLines: 7,
        maxLines: 14,
        decoration: InputDecoration(
          labelText: bodyLabel,
          alignLabelWithHint: true,
        ),
        validator: required
            ? (value) =>
                  value == null || value.trim().isEmpty ? requiredMessage : null
            : null,
      ),
    ],
  );
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

class _ShareToChannels extends ConsumerWidget {
  const _ShareToChannels({required this.selected, required this.onChanged});

  final Set<String> selected;
  final void Function(String platform, bool selected) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connections = ref.watch(socialConnectionsViewModelProvider);
    final connectedPlatforms = connections.valueOrNull?.accounts
        .where((account) => account.isConnected)
        .map((account) => account.platform)
        .toSet();

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.socialConnectionsTitle,
        helperText: l10n.shareToChannelsHelp,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ShareToChannelTile(
            label: l10n.shareToInstagramLabel,
            platform: 'instagram',
            enabled: connectedPlatforms?.contains('instagram') ?? false,
            selected: selected.contains('instagram'),
            onChanged: onChanged,
          ),
          _ShareToChannelTile(
            label: l10n.shareToFacebookLabel,
            platform: 'facebook',
            enabled: connectedPlatforms?.contains('facebook') ?? false,
            selected: selected.contains('facebook'),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ShareToChannelTile extends StatelessWidget {
  const _ShareToChannelTile({
    required this.label,
    required this.platform,
    required this.enabled,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final String platform;
  final bool enabled;
  final bool selected;
  final void Function(String platform, bool selected) onChanged;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    value: enabled ? selected : false,
    onChanged: enabled ? (value) => onChanged(platform, value ?? false) : null,
  );
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
