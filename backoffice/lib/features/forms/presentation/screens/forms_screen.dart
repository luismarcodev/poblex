import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../../core/text/filename_slug.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/managed_form.dart';
import '../forms_copy.dart';
import '../platform/form_csv_downloader.dart';
import '../viewmodels/forms_view_model.dart';

class FormsScreen extends ConsumerWidget {
  const FormsScreen({required this.onCreate, this.copy, super.key});

  final FormsCopy? copy;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = this.copy ?? AppFormsCopy(AppLocalizations.of(context));
    final forms = ref.watch(
      formsViewModelProvider.select(
        (value) => value.whenData(_FormsSnapshot.fromState),
      ),
    );
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppSize.maxWorkspaceWidth,
          ),
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(formsViewModelProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      copy: copy,
                      includeClosed: forms.valueOrNull?.includeClosed ?? false,
                      onCreate: onCreate,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),
                  ...forms.when(
                    loading: () => [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Semantics(
                          liveRegion: true,
                          label: copy.loading,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ],
                    error: (error, _) => [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ErrorState(copy: copy, error: error),
                      ),
                    ],
                    data: (state) => state.items.isEmpty
                        ? [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(child: Text(copy.empty)),
                            ),
                          ]
                        : [
                            SliverList.builder(
                              itemCount: state.items.length,
                              itemBuilder: (context, index) => _FormCard(
                                form: state.items[index],
                                copy: copy,
                              ),
                            ),
                            if (state.nextCursor != null)
                              SliverToBoxAdapter(
                                child: _LoadMore(
                                  copy: copy,
                                  loading: state.isLoadingMore,
                                ),
                              ),
                          ],
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

class _FormsSnapshot extends Equatable {
  const _FormsSnapshot({
    required this.items,
    required this.includeClosed,
    required this.nextCursor,
    required this.isLoadingMore,
  });

  factory _FormsSnapshot.fromState(FormsUiState state) => _FormsSnapshot(
    items: state.items,
    includeClosed: state.includeClosed,
    nextCursor: state.nextCursor,
    isLoadingMore: state.isLoadingMore,
  );

  final List<ManagedForm> items;
  final bool includeClosed;
  final String? nextCursor;
  final bool isLoadingMore;

  @override
  List<Object?> get props => [items, includeClosed, nextCursor, isLoadingMore];
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.copy,
    required this.includeClosed,
    required this.onCreate,
  });
  final FormsCopy copy;
  final bool includeClosed;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Text(copy.title, style: context.text.headlineLarge);
      final filter = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: includeClosed,
            onChanged: (value) => ref
                .read(formsViewModelProvider.notifier)
                .setIncludeClosed(value),
          ),
          Flexible(child: Text(copy.includeClosed)),
        ],
      );
      final add = FilledButton.icon(
        key: const Key('create-form'),
        onPressed: onCreate,
        icon: const Icon(Icons.add),
        label: Text(copy.newForm),
      );
      if (constraints.maxWidth < 900) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            const SizedBox(height: AppSpacing.sm),
            filter,
            const SizedBox(height: AppSpacing.sm),
            add,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: heading),
          filter,
          const SizedBox(width: AppSpacing.md),
          add,
        ],
      );
    },
  );
}

class _FormCard extends ConsumerWidget {
  const _FormCard({required this.form, required this.copy});
  final ManagedForm form;
  final FormsCopy copy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      formsViewModelProvider.select(
        (value) => value.valueOrNull?.busyIds.contains(form.id) ?? false,
      ),
    );
    final locale = Localizations.localeOf(context).languageCode;
    final deadline = form.deadline == null
        ? copy.noDeadline
        : copy.deadline(
            DateFormat.yMMMd(locale).add_Hm().format(form.deadline!.toLocal()),
          );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                Chip(
                  avatar: Icon(
                    form.isOpen
                        ? Icons.assignment_outlined
                        : Icons.lock_outline,
                    size: 20,
                  ),
                  label: Text(
                    form.isOpen ? copy.openStatus : copy.closedStatus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              form.title.resolve(locale == 'ca'),
              style: context.text.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(form.description.resolve(locale == 'ca')),
            const SizedBox(height: AppSpacing.md),
            _Metadata(icon: Icons.schedule, text: deadline),
            const SizedBox(height: AppSpacing.xs),
            _Metadata(
              icon: Icons.dynamic_form_outlined,
              text: copy.fieldsCount(form.fields.length),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              copy.noEditNote,
              style: context.text.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const Divider(height: AppSpacing.xl),
            if (busy)
              Semantics(
                liveRegion: true,
                label: copy.loading,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _export(context, ref),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(copy.exportSubmissions),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(copy.delete),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final result = await ref
        .read(formsViewModelProvider.notifier)
        .exportSubmissionsCsv(form);
    if (!context.mounted) return;
    if (result case Failure(error: final error)) {
      _showFailure(context, copy, error);
      return;
    }
    final csv = (result as Success<String>).value;
    final downloaded = downloadFormCsv(
      filename: 'respuestas-${filenameSlug(form.title.es)}.csv',
      csv: csv,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(downloaded ? copy.exportSuccess : copy.exportUnsupported),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(copy.deleteTitle),
        content: Text(copy.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(copy.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final failure = await ref
        .read(formsViewModelProvider.notifier)
        .delete(form);
    if (context.mounted && failure != null) {
      _showFailure(context, copy, failure);
    }
  }
}

class _Metadata extends StatelessWidget {
  const _Metadata({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ExcludeSemantics(child: Icon(icon, size: 24)),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text)),
    ],
  );
}

class _LoadMore extends ConsumerWidget {
  const _LoadMore({required this.copy, required this.loading});
  final FormsCopy copy;
  final bool loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Center(
      child: OutlinedButton.icon(
        onPressed: loading
            ? null
            : () async {
                final failure = await ref
                    .read(formsViewModelProvider.notifier)
                    .loadMore();
                if (context.mounted && failure != null) {
                  _showFailure(context, copy, failure);
                }
              },
        icon: loading
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : const Icon(Icons.expand_more),
        label: Text(copy.loadMore),
      ),
    ),
  );
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.copy, required this.error});
  final FormsCopy copy;
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_failureText(copy, error)),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => ref.invalidate(formsViewModelProvider),
          icon: const Icon(Icons.refresh),
          label: Text(copy.retry),
        ),
      ],
    ),
  );
}

void _showFailure(BuildContext context, FormsCopy copy, Object error) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(_failureText(copy, error))));
}

String _failureText(FormsCopy copy, Object error) =>
    error is NetworkFailure ? copy.networkError : copy.genericError;
