import 'dart:typed_data';

import '../../../../core/result/result.dart';
import '../entities/news_item.dart';

abstract interface class NewsRepository {
  Future<Result<NewsItem>> getById(String id);
  Future<Result<ManagedNewsPage>> getManagedNews({
    required String municipalityId,
    required bool includeArchived,
    String? cursor,
  });
  Future<Result<List<NewsItem>>> create(SaveNewsInput input);
  Future<Result<NewsItem>> update(SaveNewsInput input);
  Future<Result<NewsItem>> setPinned(String id, bool pinned);
  Future<Result<NewsItem>> setArchived(String id, bool archived);
  Future<Result<NewsAttachmentUploadTarget>> requestAttachmentUpload({
    required String newsId,
    required String fileName,
    required String mimeType,
  });
  Future<Result<void>> uploadAttachmentBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  });
  Future<Result<NewsAttachment>> confirmAttachment({
    required String newsId,
    required String name,
    required String url,
    required String mimeType,
  });
  Future<Result<void>> delete(String id);
}
