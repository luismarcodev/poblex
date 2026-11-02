import '../../../../core/result/result.dart';
import '../../../../core/errors/app_failure.dart';
import '../entities/news_item.dart';
import '../repositories/news_repository.dart';

class GetManagedNewsDetail {
  const GetManagedNewsDetail(this._repository);
  final NewsRepository _repository;
  Future<Result<NewsItem>> call(String id) => _repository.getById(id);
}

class GetManagedNews {
  const GetManagedNews(this._repository);
  final NewsRepository _repository;
  Future<Result<ManagedNewsPage>> call({
    required String municipalityId,
    required bool includeArchived,
    String? cursor,
  }) => _repository.getManagedNews(
    municipalityId: municipalityId,
    includeArchived: includeArchived,
    cursor: cursor,
  );
}

class SaveNews {
  const SaveNews(this._repository);
  final NewsRepository _repository;
  Future<Result<List<NewsItem>>> call(SaveNewsInput input) async {
    if (!input.isEditing) return _repository.create(input);
    final result = await _repository.update(input);
    return switch (result) {
      Success(value: final item) => Success([item]),
      Failure(error: final error) => Failure(error),
    };
  }
}

class UploadNewsAttachment {
  const UploadNewsAttachment(this._repository);

  static const int maxBytes = 5 * 1024 * 1024;
  static const String tooLargeCode = 'attachment_too_large';
  static const String unsupportedTypeCode = 'attachment_unsupported_type';
  static const String invalidFileCode = 'attachment_invalid_file';

  final NewsRepository _repository;

  Future<Result<NewsAttachment>> call(
    String newsId,
    NewsAttachmentUploadFile file,
  ) async {
    if (file.bytes.isEmpty || file.name.trim().isEmpty) {
      return const Failure(ValidationFailure(message: invalidFileCode));
    }
    if (file.bytes.length > maxBytes) {
      return const Failure(ValidationFailure(message: tooLargeCode));
    }
    final mimeType = detectMimeType(file.bytes);
    if (mimeType == null) {
      return const Failure(ValidationFailure(message: unsupportedTypeCode));
    }

    final targetResult = await _repository.requestAttachmentUpload(
      newsId: newsId,
      fileName: _safeName(file.name),
      mimeType: mimeType,
    );
    if (targetResult case Failure(error: final error)) {
      return Failure(error);
    }
    final target = (targetResult as Success<NewsAttachmentUploadTarget>).value;

    final uploadResult = await _repository.uploadAttachmentBytes(
      uploadUrl: target.uploadUrl,
      bytes: file.bytes,
      mimeType: mimeType,
    );
    if (uploadResult case Failure(error: final error)) {
      return Failure(error);
    }

    return _repository.confirmAttachment(
      newsId: newsId,
      name: _safeName(file.name),
      url: target.publicUrl,
      mimeType: mimeType,
    );
  }

  static String? detectMimeType(List<int> bytes) {
    if (_startsWith(bytes, const [0x25, 0x50, 0x44, 0x46, 0x2D])) {
      return 'application/pdf';
    }
    if (_startsWith(bytes, const [0xFF, 0xD8, 0xFF])) {
      return 'image/jpeg';
    }
    if (_startsWith(bytes, const [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
    ])) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        _matchesAt(bytes, 0, const [0x52, 0x49, 0x46, 0x46]) &&
        _matchesAt(bytes, 8, const [0x57, 0x45, 0x42, 0x50])) {
      return 'image/webp';
    }
    return null;
  }

  static bool _startsWith(List<int> bytes, List<int> signature) =>
      _matchesAt(bytes, 0, signature);

  static bool _matchesAt(List<int> bytes, int offset, List<int> signature) {
    if (bytes.length < offset + signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[offset + index] != signature[index]) return false;
    }
    return true;
  }

  static String _safeName(String value) {
    final segments = value.trim().split(RegExp(r'[/\\]'));
    return segments.last;
  }
}

class SetNewsPinned {
  const SetNewsPinned(this._repository);
  final NewsRepository _repository;
  Future<Result<NewsItem>> call(String id, bool value) =>
      _repository.setPinned(id, value);
}

class SetNewsArchived {
  const SetNewsArchived(this._repository);
  final NewsRepository _repository;
  Future<Result<NewsItem>> call(String id, bool value) =>
      _repository.setArchived(id, value);
}

class DeleteNews {
  const DeleteNews(this._repository);
  final NewsRepository _repository;
  Future<Result<void>> call(String id) => _repository.delete(id);
}

class ListNewsCategories {
  const ListNewsCategories(this._repository);
  final NewsRepository _repository;
  Future<Result<List<String>>> call(String municipalityId) =>
      _repository.getCategories(municipalityId);
}
