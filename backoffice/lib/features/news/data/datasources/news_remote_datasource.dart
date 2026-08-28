import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../domain/entities/news_item.dart';
import '../models/news_item_model.dart';

class NewsRemoteDataSource {
  NewsRemoteDataSource(this._dio, {Dio? uploadDio})
    : _uploadDio = uploadDio ?? Dio();
  final Dio _dio;
  final Dio _uploadDio;

  Future<NewsItem> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/admin/news/$id');
    return _entity(response.data);
  }

  Future<ManagedNewsPage> getManagedNews({
    required String municipalityId,
    required bool includeArchived,
    String? cursor,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/admin/news',
      queryParameters: {
        'municipalityId': municipalityId,
        'includeArchived': includeArchived,
        'limit': 20,
        'cursor': ?cursor,
      },
    );
    final data = response.data;
    if (data == null) throw const FormatException('Missing news page');
    final rawItems = data['items'] as List<dynamic>;
    return ManagedNewsPage(
      items: rawItems
          .map(
            (raw) => NewsItemModel.fromJson(raw as Map<String, dynamic>).entity,
          )
          .toList(growable: false),
      nextCursor: data['nextCursor'] as String?,
    );
  }

  Future<List<NewsItem>> create(SaveNewsInput input) async {
    final response = await _dio.post<List<dynamic>>(
      '/admin/news',
      data: {
        'municipalityIds': input.municipalityIds,
        'title': input.title.toJson(),
        'body': input.body.toJson(),
        'category': input.category,
        if (input.imageUrl != null) 'imageUrl': input.imageUrl,
        'pinned': input.pinned,
        if (input.shareToChannels.isNotEmpty)
          'shareToChannels': input.shareToChannels.toList(growable: false),
      },
    );
    return (response.data ?? const [])
        .map(
          (raw) => NewsItemModel.fromJson(raw as Map<String, dynamic>).entity,
        )
        .toList(growable: false);
  }

  Future<NewsItem> update(SaveNewsInput input) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/news/${input.id}',
      data: {
        'title': input.title.toJson(),
        'body': input.body.toJson(),
        'category': input.category,
        'imageUrl': input.imageUrl,
      },
    );
    return _entity(response.data);
  }

  Future<NewsItem> setPinned(String id, bool pinned) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/news/$id/pin',
      data: {'pinned': pinned},
    );
    return _entity(response.data);
  }

  Future<NewsItem> setArchived(String id, bool archived) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/admin/news/$id/archived',
      data: {'archived': archived},
    );
    return _entity(response.data);
  }

  Future<NewsAttachmentUploadTarget> requestAttachmentUpload({
    required String newsId,
    required String fileName,
    required String mimeType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/news/$newsId/attachments/upload-url',
      data: {'fileName': fileName, 'contentType': mimeType},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Missing attachment upload target');
    }
    return NewsAttachmentUploadTarget(
      uploadUrl: data['uploadUrl'] as String,
      publicUrl: data['publicUrl'] as String,
      expiresInSeconds: data['expiresInSeconds'] as int,
    );
  }

  Future<void> uploadAttachmentBytes({
    required String uploadUrl,
    required Uint8List bytes,
    required String mimeType,
  }) => _uploadDio.put<void>(
    uploadUrl,
    data: bytes,
    options: Options(headers: {'Content-Type': mimeType}),
  );

  Future<NewsAttachment> confirmAttachment({
    required String newsId,
    required String name,
    required String url,
    required String mimeType,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/admin/news/$newsId/attachments',
      data: {'name': name, 'url': url, 'mimeType': mimeType},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('Missing confirmed attachment');
    }
    return NewsAttachment(
      id: data['id'] as String,
      name: data['name'] as String,
      url: data['url'] as String,
      mimeType: data['mimeType'] as String,
    );
  }

  Future<void> delete(String id) => _dio.delete<void>('/admin/news/$id');

  NewsItem _entity(Map<String, dynamic>? data) {
    if (data == null) throw const FormatException('Missing news item');
    return NewsItemModel.fromJson(data).entity;
  }
}
