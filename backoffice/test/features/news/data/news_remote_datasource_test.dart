import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/news/data/datasources/news_remote_datasource.dart';
import 'package:poblex_backoffice/features/news/domain/entities/news_item.dart';

void main() {
  test('sends an explicit null when removing the current image', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: _response,
            ),
          );
        },
      ),
    );
    final dataSource = NewsRemoteDataSource(dio);

    await dataSource.update(
      const SaveNewsInput(
        id: 'news-1',
        title: LocalizedText(es: 'Corte de agua'),
        body: LocalizedText(es: 'Desde las diez'),
        category: 'servicios',
        imageUrl: null,
        pinned: false,
        municipalityIds: ['municipality-1'],
      ),
    );

    expect(captured.path, '/admin/news/news-1');
    expect(captured.data, containsPair('imageUrl', null));
  });

  test(
    'uses the presigned upload URL and then confirms the attachment',
    () async {
      final apiDio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      final uploadDio = Dio();
      final apiRequests = <RequestOptions>[];
      late RequestOptions uploadRequest;
      apiDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            apiRequests.add(options);
            if (options.path.endsWith('/upload-url')) {
              handler.resolve(
                Response<Map<String, dynamic>>(
                  requestOptions: options,
                  statusCode: 201,
                  data: {
                    'uploadUrl': 'https://storage.test/signed',
                    'publicUrl': 'https://cdn.test/bando.pdf',
                    'expiresInSeconds': 300,
                  },
                ),
              );
              return;
            }
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'id': 'attachment-1',
                  'name': 'bando.pdf',
                  'url': 'https://cdn.test/bando.pdf',
                  'mimeType': 'application/pdf',
                },
              ),
            );
          },
        ),
      );
      uploadDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            uploadRequest = options;
            handler.resolve(
              Response<void>(requestOptions: options, statusCode: 200),
            );
          },
        ),
      );
      final dataSource = NewsRemoteDataSource(apiDio, uploadDio: uploadDio);

      final target = await dataSource.requestAttachmentUpload(
        newsId: 'news-1',
        fileName: 'bando.pdf',
        mimeType: 'application/pdf',
      );
      await dataSource.uploadAttachmentBytes(
        uploadUrl: target.uploadUrl,
        bytes: Uint8List.fromList(const [0x25, 0x50, 0x44, 0x46, 0x2D]),
        mimeType: 'application/pdf',
      );
      final attachment = await dataSource.confirmAttachment(
        newsId: 'news-1',
        name: 'bando.pdf',
        url: target.publicUrl,
        mimeType: 'application/pdf',
      );

      expect(apiRequests, hasLength(2));
      expect(
        apiRequests.first.path,
        '/admin/news/news-1/attachments/upload-url',
      );
      expect(apiRequests.first.data, {
        'fileName': 'bando.pdf',
        'contentType': 'application/pdf',
      });
      expect(uploadRequest.uri.toString(), 'https://storage.test/signed');
      expect(uploadRequest.headers['Content-Type'], 'application/pdf');
      expect(apiRequests.last.path, '/admin/news/news-1/attachments');
      expect(attachment.name, 'bando.pdf');
    },
  );
}

final Map<String, dynamic> _response = {
  'id': 'news-1',
  'municipalityId': 'municipality-1',
  'title': {'es': 'Corte de agua'},
  'body': {'es': 'Desde las diez'},
  'imageUrl': null,
  'category': 'servicios',
  'pinned': false,
  'publishedAt': '2026-08-09T10:00:00.000Z',
  'archived': false,
  'attachments': <dynamic>[],
};
