import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/news/domain/entities/news_item.dart';
import 'package:poblex_backoffice/features/news/domain/repositories/news_repository.dart';
import 'package:poblex_backoffice/features/news/domain/usecases/news_usecases.dart';

void main() {
  group('UploadNewsAttachment', () {
    late FakeAttachmentRepository repository;
    late UploadNewsAttachment useCase;

    setUp(() {
      repository = FakeAttachmentRepository();
      useCase = UploadNewsAttachment(repository);
    });

    test('uploads and confirms a PDF using its real signature', () async {
      final result = await useCase(
        'news-1',
        NewsAttachmentUploadFile(
          name: r'C:\fakepath\bando.pdf',
          bytes: Uint8List.fromList('%PDF-1.7 content'.codeUnits),
        ),
      );

      expect(result, isA<Success<NewsAttachment>>());
      expect(repository.requestedFileName, 'bando.pdf');
      expect(repository.requestedMimeType, 'application/pdf');
      expect(repository.uploadedMimeType, 'application/pdf');
      expect(repository.confirmedUrl, 'https://cdn.test/bando.pdf');
    });

    test('recognises JPEG, PNG and WebP by content', () {
      expect(
        UploadNewsAttachment.detectMimeType([0xFF, 0xD8, 0xFF, 0x00]),
        'image/jpeg',
      );
      expect(
        UploadNewsAttachment.detectMimeType([
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A,
        ]),
        'image/png',
      );
      expect(
        UploadNewsAttachment.detectMimeType([
          0x52,
          0x49,
          0x46,
          0x46,
          0,
          0,
          0,
          0,
          0x57,
          0x45,
          0x42,
          0x50,
        ]),
        'image/webp',
      );
    });

    test('rejects files over 5 MB before contacting the backend', () async {
      final result = await useCase(
        'news-1',
        NewsAttachmentUploadFile(
          name: 'huge.pdf',
          bytes: Uint8List(UploadNewsAttachment.maxBytes + 1),
        ),
      );

      expect(
        result,
        isA<Failure<NewsAttachment>>().having(
          (failure) => failure.error,
          'error',
          const ValidationFailure(message: UploadNewsAttachment.tooLargeCode),
        ),
      );
      expect(repository.requestCalls, 0);
    });

    test('rejects a renamed executable by inspecting its bytes', () async {
      final result = await useCase(
        'news-1',
        NewsAttachmentUploadFile(
          name: 'not-an-image.png',
          bytes: Uint8List.fromList([0x4D, 0x5A, 0x90, 0x00]),
        ),
      );

      expect(
        result,
        isA<Failure<NewsAttachment>>().having(
          (failure) => failure.error.message,
          'code',
          UploadNewsAttachment.unsupportedTypeCode,
        ),
      );
      expect(repository.requestCalls, 0);
    });
  });
}

class FakeAttachmentRepository implements NewsRepository {
  int requestCalls = 0;
  String? requestedFileName;
  String? requestedMimeType;
  String? uploadedMimeType;
  String? confirmedUrl;

  @override
  Future<Result<NewsAttachmentUploadTarget>> requestAttachmentUpload({
    required String newsId,
    required String fileName,
    required String mimeType,
  }) async {
    requestCalls++;
    requestedFileName = fileName;
    requestedMimeType = mimeType;
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
  }) async {
    uploadedMimeType = mimeType;
    return const Success(null);
  }

  @override
  Future<Result<NewsAttachment>> confirmAttachment({
    required String newsId,
    required String name,
    required String url,
    required String mimeType,
  }) async {
    confirmedUrl = url;
    return Success(
      NewsAttachment(
        id: 'attachment-1',
        name: name,
        url: url,
        mimeType: mimeType,
      ),
    );
  }

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
}
