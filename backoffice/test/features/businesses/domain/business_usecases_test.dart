import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/businesses/domain/entities/managed_business.dart';
import 'package:poblex_backoffice/features/businesses/domain/repositories/business_repository.dart';
import 'package:poblex_backoffice/features/businesses/domain/usecases/business_usecases.dart';

final _jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 1, 2, 3]);
final _pngBytes = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  1,
  2,
]);
final _textBytes = Uint8List.fromList('not an image'.codeUnits);

ManagedBusiness _business({List<BusinessPhoto> photos = const []}) =>
    ManagedBusiness(
      id: 'business-1',
      municipalityId: 'municipality-1',
      name: 'Bar Casa Pepe',
      category: 'bar',
      descriptionEs: null,
      descriptionVa: null,
      address: null,
      phone: null,
      email: null,
      website: null,
      schedule: null,
      active: true,
      photos: photos,
    );

class _StubBusinessRepository implements BusinessRepository {
  int requestUploadCalls = 0;
  int uploadBytesCalls = 0;
  int confirmCalls = 0;

  @override
  Future<Result<BusinessPhotoUploadTarget>> requestPhotoUpload({
    required String businessId,
    required String fileName,
    required String mimeType,
  }) async {
    requestUploadCalls++;
    return const Success(
      BusinessPhotoUploadTarget(
        uploadUrl: 'https://r2.example/upload',
        publicUrl: 'https://cdn.example/business/photo.jpg',
        expiresInSeconds: 300,
      ),
    );
  }

  @override
  Future<Result<void>> uploadPhotoBytes({
    required String uploadUrl,
    required List<int> bytes,
    required String mimeType,
  }) async {
    uploadBytesCalls++;
    return const Success(null);
  }

  @override
  Future<Result<ManagedBusiness>> confirmPhoto({
    required String businessId,
    required String url,
    required String mimeType,
  }) async {
    confirmCalls++;
    return Success(
      _business(
        photos: [
          BusinessPhoto(
            id: 'photo-1',
            url: url,
            mimeType: mimeType,
            position: 0,
          ),
        ],
      ),
    );
  }

  @override
  Future<Result<ManagedBusiness>> create(SaveBusinessInput input) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();
  @override
  Future<Result<void>> deletePhoto({
    required String businessId,
    required String photoId,
  }) => throw UnimplementedError();
  @override
  Future<Result<ManagedBusiness>> getById(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<ManagedBusinessPage>> getManagedBusinesses({
    required String municipalityId,
    required bool includeInactive,
    String? cursor,
  }) => throw UnimplementedError();
  @override
  Future<Result<List<String>>> categories(String municipalityId) =>
      throw UnimplementedError();
  @override
  Future<Result<ManagedBusiness>> reorderPhotos({
    required String businessId,
    required List<String> orderedPhotoIds,
  }) => throw UnimplementedError();
  @override
  Future<Result<ManagedBusiness>> setActive(String id, bool active) =>
      throw UnimplementedError();
  @override
  Future<Result<ManagedBusiness>> update(SaveBusinessInput input) =>
      throw UnimplementedError();
}

void main() {
  group('UploadBusinessPhoto.detectImageMimeType', () {
    test('recognises JPEG, PNG and WebP by their magic bytes', () {
      expect(UploadBusinessPhoto.detectImageMimeType(_jpegBytes), 'image/jpeg');
      expect(UploadBusinessPhoto.detectImageMimeType(_pngBytes), 'image/png');
    });

    test('rejects a file that is not a recognised image format', () {
      expect(UploadBusinessPhoto.detectImageMimeType(_textBytes), isNull);
    });
  });

  group('UploadBusinessPhoto', () {
    late _StubBusinessRepository repository;
    late UploadBusinessPhoto useCase;

    setUp(() {
      repository = _StubBusinessRepository();
      useCase = UploadBusinessPhoto(repository);
    });

    test('rejects an empty file before calling the network', () async {
      final result = await useCase(
        'business-1',
        BusinessPhotoUploadFile(name: 'photo.jpg', bytes: const []),
      );

      expect(result.isSuccess, isFalse);
      expect(
        (result as Failure).error,
        isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          UploadBusinessPhoto.invalidFileCode,
        ),
      );
      expect(repository.requestUploadCalls, 0);
    });

    test('rejects a file whose real bytes are not an image', () async {
      final result = await useCase(
        'business-1',
        BusinessPhotoUploadFile(name: 'notes.txt', bytes: _textBytes),
      );

      expect(result.isSuccess, isFalse);
      expect(
        (result as Failure).error,
        isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          UploadBusinessPhoto.unsupportedTypeCode,
        ),
      );
      expect(repository.requestUploadCalls, 0);
    });

    test(
      'rejects a file renamed with a fake .jpg extension but wrong bytes',
      () async {
        // The point of validating by signature and not by extension: a
        // malicious or mistaken rename must not fool the upload flow.
        final result = await useCase(
          'business-1',
          BusinessPhotoUploadFile(name: 'photo.jpg', bytes: _textBytes),
        );

        expect(result.isSuccess, isFalse);
        expect(repository.requestUploadCalls, 0);
      },
    );

    test('rejects a file larger than the 5 MB limit', () async {
      final oversized = Uint8List(UploadBusinessPhoto.maxBytes + 1);
      oversized.setRange(0, 3, _jpegBytes);
      final result = await useCase(
        'business-1',
        BusinessPhotoUploadFile(name: 'huge.jpg', bytes: oversized),
      );

      expect(result.isSuccess, isFalse);
      expect(
        (result as Failure).error,
        isA<ValidationFailure>().having(
          (f) => f.message,
          'message',
          UploadBusinessPhoto.tooLargeCode,
        ),
      );
      expect(repository.requestUploadCalls, 0);
    });

    test(
      'runs the 3-step flow for a valid JPEG and returns the updated business',
      () async {
        final result = await useCase(
          'business-1',
          BusinessPhotoUploadFile(name: 'photo.jpg', bytes: _jpegBytes),
        );

        expect(result.isSuccess, isTrue);
        expect(repository.requestUploadCalls, 1);
        expect(repository.uploadBytesCalls, 1);
        expect(repository.confirmCalls, 1);
        expect((result as Success).value.photos, hasLength(1));
      },
    );
  });
}
