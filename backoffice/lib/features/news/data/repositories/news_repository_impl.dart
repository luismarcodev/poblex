import 'dart:typed_data';

import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/news_remote_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  const NewsRepositoryImpl(this._remote);
  final NewsRemoteDataSource _remote;

  @override
  Future<Result<NewsItem>> getById(String id) =>
      _capture(() => _remote.getById(id));

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedNewsPage>> getManagedNews({
    required String municipalityId,
    required bool includeArchived,
    String? cursor,
  }) => _capture(
    () => _remote.getManagedNews(
      municipalityId: municipalityId,
      includeArchived: includeArchived,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<List<NewsItem>>> create(SaveNewsInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<NewsItem>> update(SaveNewsInput input) =>
      _capture(() => _remote.update(input));

  @override
  Future<Result<NewsItem>> setPinned(String id, bool pinned) =>
      _capture(() => _remote.setPinned(id, pinned));

  @override
  Future<Result<NewsItem>> setArchived(String id, bool archived) =>
      _capture(() => _remote.setArchived(id, archived));

  @override
  Future<Result<NewsAttachmentUploadTarget>> requestAttachmentUpload({
    required String newsId,
    required String fileName,
    required String mimeType,
  }) => _capture(
    () => _remote.requestAttachmentUpload(
      newsId: newsId,
      fileName: fileName,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<void>> uploadAttachmentBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  }) => _capture(
    () => _remote.uploadAttachmentBytes(
      uploadUrl: uploadUrl,
      bytes: bytes,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<NewsAttachment>> confirmAttachment({
    required String newsId,
    required String name,
    required String url,
    required String mimeType,
  }) => _capture(
    () => _remote.confirmAttachment(
      newsId: newsId,
      name: name,
      url: url,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<void>> delete(String id) => _capture(() => _remote.delete(id));
}
