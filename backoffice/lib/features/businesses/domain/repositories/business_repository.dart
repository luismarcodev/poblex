import '../../../../core/result/result.dart';
import '../entities/managed_business.dart';

abstract interface class BusinessRepository {
  Future<Result<ManagedBusiness>> getById(String id);

  Future<Result<ManagedBusinessPage>> getManagedBusinesses({
    required String municipalityId,
    required bool includeInactive,
    String? cursor,
  });

  Future<Result<List<String>>> categories(String municipalityId);

  Future<Result<ManagedBusiness>> create(SaveBusinessInput input);
  Future<Result<ManagedBusiness>> update(SaveBusinessInput input);
  Future<Result<ManagedBusiness>> setActive(String id, bool active);
  Future<Result<void>> delete(String id);

  Future<Result<BusinessPhotoUploadTarget>> requestPhotoUpload({
    required String businessId,
    required String fileName,
    required String mimeType,
  });
  Future<Result<void>> uploadPhotoBytes({
    required String uploadUrl,
    required List<int> bytes,
    required String mimeType,
  });
  Future<Result<ManagedBusiness>> confirmPhoto({
    required String businessId,
    required String url,
    required String mimeType,
  });
  Future<Result<void>> deletePhoto({
    required String businessId,
    required String photoId,
  });
  Future<Result<ManagedBusiness>> reorderPhotos({
    required String businessId,
    required List<String> orderedPhotoIds,
  });
}
