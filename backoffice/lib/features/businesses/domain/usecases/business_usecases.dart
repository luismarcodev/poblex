import '../../../../core/result/result.dart';
import '../../../../core/errors/app_failure.dart';
import '../entities/managed_business.dart';
import '../repositories/business_repository.dart';

class GetManagedBusinessDetail {
  const GetManagedBusinessDetail(this._repository);
  final BusinessRepository _repository;
  Future<Result<ManagedBusiness>> call(String id) => _repository.getById(id);
}

class GetManagedBusinesses {
  const GetManagedBusinesses(this._repository);
  final BusinessRepository _repository;
  Future<Result<ManagedBusinessPage>> call({
    required String municipalityId,
    required bool includeInactive,
    String? cursor,
  }) => _repository.getManagedBusinesses(
    municipalityId: municipalityId,
    includeInactive: includeInactive,
    cursor: cursor,
  );
}

class GetBusinessCategories {
  const GetBusinessCategories(this._repository);
  final BusinessRepository _repository;
  Future<Result<List<String>>> call(String municipalityId) =>
      _repository.categories(municipalityId);
}

class SaveBusiness {
  const SaveBusiness(this._repository);
  final BusinessRepository _repository;
  Future<Result<ManagedBusiness>> call(SaveBusinessInput input) =>
      input.isEditing ? _repository.update(input) : _repository.create(input);
}

class SetBusinessActive {
  const SetBusinessActive(this._repository);
  final BusinessRepository _repository;
  Future<Result<ManagedBusiness>> call(String id, bool active) =>
      _repository.setActive(id, active);
}

class DeleteBusiness {
  const DeleteBusiness(this._repository);
  final BusinessRepository _repository;
  Future<Result<void>> call(String id) => _repository.delete(id);
}

/// Sube y confirma una foto en 3 pasos: URL prefirmada, PUT directo a R2,
/// confirmación. Mismo patrón que `UploadNewsAttachment`, pero solo imágenes
/// — un comercio no adjunta PDFs — y valida el tipo real por firma de bytes
/// antes de gastar una petición de red.
class UploadBusinessPhoto {
  const UploadBusinessPhoto(this._repository);

  static const int maxBytes = 5 * 1024 * 1024;
  static const String tooLargeCode = 'photo_too_large';
  static const String unsupportedTypeCode = 'photo_unsupported_type';
  static const String invalidFileCode = 'photo_invalid_file';

  final BusinessRepository _repository;

  Future<Result<ManagedBusiness>> call(
    String businessId,
    BusinessPhotoUploadFile file,
  ) async {
    if (file.bytes.isEmpty || file.name.trim().isEmpty) {
      return const Failure(ValidationFailure(message: invalidFileCode));
    }
    if (file.bytes.length > maxBytes) {
      return const Failure(ValidationFailure(message: tooLargeCode));
    }
    final mimeType = detectImageMimeType(file.bytes);
    if (mimeType == null) {
      return const Failure(ValidationFailure(message: unsupportedTypeCode));
    }

    final targetResult = await _repository.requestPhotoUpload(
      businessId: businessId,
      fileName: _safeName(file.name),
      mimeType: mimeType,
    );
    if (targetResult case Failure(error: final error)) {
      return Failure(error);
    }
    final target = (targetResult as Success<BusinessPhotoUploadTarget>).value;

    final uploadResult = await _repository.uploadPhotoBytes(
      uploadUrl: target.uploadUrl,
      bytes: file.bytes,
      mimeType: mimeType,
    );
    if (uploadResult case Failure(error: final error)) {
      return Failure(error);
    }

    return _repository.confirmPhoto(
      businessId: businessId,
      url: target.publicUrl,
      mimeType: mimeType,
    );
  }

  static String? detectImageMimeType(List<int> bytes) {
    if (_startsWith(bytes, const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
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

class DeleteBusinessPhoto {
  const DeleteBusinessPhoto(this._repository);
  final BusinessRepository _repository;
  Future<Result<void>> call({
    required String businessId,
    required String photoId,
  }) => _repository.deletePhoto(businessId: businessId, photoId: photoId);
}

class ReorderBusinessPhotos {
  const ReorderBusinessPhotos(this._repository);
  final BusinessRepository _repository;
  Future<Result<ManagedBusiness>> call({
    required String businessId,
    required List<String> orderedPhotoIds,
  }) => _repository.reorderPhotos(
    businessId: businessId,
    orderedPhotoIds: orderedPhotoIds,
  );
}
