import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/di/injection_container.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/news/domain/entities/news_item.dart';
import 'package:poblex_backoffice/features/news/domain/repositories/news_repository.dart';
import 'package:poblex_backoffice/features/news/domain/usecases/news_usecases.dart';
import 'package:poblex_backoffice/features/news/presentation/viewmodels/news_editor_view_model.dart';

void main() {
  late RetryAttachmentRepository repository;
  late ProviderContainer container;

  setUp(() async {
    await getIt.reset();
    repository = RetryAttachmentRepository();
    getIt.registerFactory(() => UploadNewsAttachment(repository));
    container = ProviderContainer();
    container.listen(newsEditorViewModelProvider, (_, _) {});
    await container
        .read(newsEditorViewModelProvider.notifier)
        .load('news-1', initial: _news);
  });

  tearDown(() async {
    container.dispose();
    await getIt.reset();
  });

  test(
    'keeps the failed file and retries it without selecting it again',
    () async {
      final viewModel = container.read(newsEditorViewModelProvider.notifier);
      final file = NewsAttachmentUploadFile(
        name: 'bando.pdf',
        bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
      );

      final firstFailure = await viewModel.uploadAttachment(file);

      expect(firstFailure, isA<NetworkFailure>());
      expect(
        container
            .read(newsEditorViewModelProvider)
            .requireValue
            .failedAttachment,
        same(file),
      );

      final retryFailure = await viewModel.retryAttachment();
      final state = container.read(newsEditorViewModelProvider).requireValue;

      expect(retryFailure, isNull);
      expect(repository.requestCalls, 2);
      expect(state.failedAttachment, isNull);
      expect(state.attachmentFailure, isNull);
      expect(state.item!.attachments.single.name, 'bando.pdf');
    },
  );
}

final _news = NewsItem(
  id: 'news-1',
  municipalityId: 'sollana',
  title: const LocalizedText(es: 'Bando municipal'),
  body: const LocalizedText(es: 'Información importante'),
  category: 'general',
  pinned: false,
  publishedAt: DateTime.utc(2026, 8, 10),
  archived: false,
  attachments: const [],
);

class RetryAttachmentRepository implements NewsRepository {
  int requestCalls = 0;

  @override
  Future<Result<NewsAttachmentUploadTarget>> requestAttachmentUpload({
    required String newsId,
    required String fileName,
    required String mimeType,
  }) async {
    requestCalls++;
    if (requestCalls == 1) return const Failure(NetworkFailure());
    return const Success(
      NewsAttachmentUploadTarget(
        uploadUrl: 'https://storage.test/signed',
        publicUrl: 'https://cdn.test/bando.pdf',
        expiresInSeconds: 300,
      ),
    );
  }

  @override
  Future<Result<void>> uploadAttachmentBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  }) async => const Success(null);

  @override
  Future<Result<NewsAttachment>> confirmAttachment({
    required String newsId,
    required String name,
    required String url,
    required String mimeType,
  }) async => Success(
    NewsAttachment(
      id: 'attachment-1',
      name: name,
      url: url,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<List<NewsItem>>> create(SaveNewsInput input) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();
  @override
  Future<Result<NewsItem>> getById(String id) => throw UnimplementedError();
  @override
  Future<Result<ManagedNewsPage>> getManagedNews({
    required String municipalityId,
    required bool includeArchived,
    String? cursor,
  }) => throw UnimplementedError();
  @override
  Future<Result<NewsItem>> setArchived(String id, bool archived) =>
      throw UnimplementedError();
  @override
  Future<Result<NewsItem>> setPinned(String id, bool pinned) =>
      throw UnimplementedError();
  @override
  Future<Result<NewsItem>> update(SaveNewsInput input) =>
      throw UnimplementedError();
  @override
  Future<Result<List<String>>> getCategories(String municipalityId) async =>
      const Success([]);
}
