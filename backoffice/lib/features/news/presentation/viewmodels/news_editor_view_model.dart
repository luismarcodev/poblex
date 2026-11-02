import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/usecases/news_usecases.dart';

class NewsEditorUiState extends Equatable {
  const NewsEditorUiState({
    this.item,
    this.uploadingAttachment = false,
    this.failedAttachment,
    this.attachmentFailure,
  });

  final NewsItem? item;
  final bool uploadingAttachment;
  final NewsAttachmentUploadFile? failedAttachment;
  final AppFailure? attachmentFailure;

  NewsEditorUiState copyWith({
    NewsItem? item,
    bool? uploadingAttachment,
    NewsAttachmentUploadFile? failedAttachment,
    AppFailure? attachmentFailure,
    bool clearAttachmentFailure = false,
  }) => NewsEditorUiState(
    item: item ?? this.item,
    uploadingAttachment: uploadingAttachment ?? this.uploadingAttachment,
    failedAttachment: clearAttachmentFailure
        ? null
        : failedAttachment ?? this.failedAttachment,
    attachmentFailure: clearAttachmentFailure
        ? null
        : attachmentFailure ?? this.attachmentFailure,
  );

  @override
  List<Object?> get props => [
    item,
    uploadingAttachment,
    failedAttachment,
    attachmentFailure,
  ];
}

final newsCategoriesProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, municipalityId) async {
      final result = await getIt<ListNewsCategories>()(municipalityId);
      return switch (result) {
        Success(value: final categories) => categories,
        Failure() => const <String>[],
      };
    });

final newsEditorViewModelProvider =
    AsyncNotifierProvider.autoDispose<NewsEditorViewModel, NewsEditorUiState>(
      NewsEditorViewModel.new,
    );

class NewsEditorViewModel extends AutoDisposeAsyncNotifier<NewsEditorUiState> {
  @override
  NewsEditorUiState build() => const NewsEditorUiState();

  Future<void> load(String id, {NewsItem? initial}) async {
    if (initial != null) {
      state = AsyncData(NewsEditorUiState(item: initial));
      return;
    }
    state = const AsyncLoading();
    final result = await getIt<GetManagedNewsDetail>()(id);
    state = switch (result) {
      Success(value: final item) => AsyncData(NewsEditorUiState(item: item)),
      Failure(error: final error) => AsyncError(error, StackTrace.current),
    };
  }

  Future<AppFailure?> save(SaveNewsInput input) async {
    final previous = state.valueOrNull ?? const NewsEditorUiState();
    state = const AsyncLoading();
    final result = await getIt<SaveNews>()(input);
    return switch (result) {
      Success() => _complete(previous),
      Failure(error: final error) => _fail(previous, error),
    };
  }

  Future<AppFailure?> uploadAttachment(NewsAttachmentUploadFile file) async {
    final previous = state.valueOrNull;
    final item = previous?.item;
    if (previous == null || item == null || previous.uploadingAttachment) {
      return const ValidationFailure(
        message: UploadNewsAttachment.invalidFileCode,
      );
    }

    state = AsyncData(
      previous.copyWith(
        uploadingAttachment: true,
        clearAttachmentFailure: true,
      ),
    );
    final result = await getIt<UploadNewsAttachment>()(item.id, file);
    return switch (result) {
      Success(value: final attachment) => _completeAttachment(
        previous,
        attachment,
      ),
      Failure(error: final error) => _failAttachment(previous, file, error),
    };
  }

  Future<AppFailure?> retryAttachment() async {
    final file = state.valueOrNull?.failedAttachment;
    if (file == null) {
      return const ValidationFailure(
        message: UploadNewsAttachment.invalidFileCode,
      );
    }
    return uploadAttachment(file);
  }

  AppFailure? _completeAttachment(
    NewsEditorUiState previous,
    NewsAttachment attachment,
  ) {
    final item = previous.item!;
    state = AsyncData(
      previous.copyWith(
        item: item.copyWith(attachments: [...item.attachments, attachment]),
        uploadingAttachment: false,
        clearAttachmentFailure: true,
      ),
    );
    return null;
  }

  AppFailure _failAttachment(
    NewsEditorUiState previous,
    NewsAttachmentUploadFile file,
    AppFailure error,
  ) {
    state = AsyncData(
      previous.copyWith(
        uploadingAttachment: false,
        failedAttachment: file,
        attachmentFailure: error,
      ),
    );
    return error;
  }

  AppFailure? _complete(NewsEditorUiState previous) {
    state = AsyncData(previous);
    return null;
  }

  AppFailure _fail(NewsEditorUiState previous, AppFailure error) {
    state = AsyncData(previous);
    return error;
  }
}
