import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_remote_datasource.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  const BusinessRepositoryImpl(this._remote);
  final BusinessRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedBusiness>> getById(String id) =>
      _capture(() => _remote.getById(id));

  @override
  Future<Result<ManagedBusinessPage>> getManagedBusinesses({
    required String municipalityId,
    required bool includeInactive,
    String? cursor,
  }) => _capture(
    () => _remote.getManagedBusinesses(
      municipalityId: municipalityId,
      includeInactive: includeInactive,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<List<String>>> categories(String municipalityId) =>
      _capture(() => _remote.categories(municipalityId));

  @override
  Future<Result<ManagedBusiness>> create(SaveBusinessInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<ManagedBusiness>> update(SaveBusinessInput input) =>
      _capture(() => _remote.update(input));

  @override
  Future<Result<ManagedBusiness>> setActive(String id, bool active) =>
      _capture(() => _remote.setActive(id, active));

  @override
  Future<Result<void>> delete(String id) => _capture(() => _remote.delete(id));

  @override
  Future<Result<BusinessPhotoUploadTarget>> requestPhotoUpload({
    required String businessId,
    required String fileName,
    required String mimeType,
  }) => _capture(
    () => _remote.requestPhotoUpload(
      businessId: businessId,
      fileName: fileName,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<void>> uploadPhotoBytes({
    required String uploadUrl,
    required List<int> bytes,
    required String mimeType,
  }) => _capture(
    () => _remote.uploadPhotoBytes(
      uploadUrl: uploadUrl,
      bytes: bytes,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<ManagedBusiness>> confirmPhoto({
    required String businessId,
    required String url,
    required String mimeType,
  }) => _capture(
    () => _remote.confirmPhoto(
      businessId: businessId,
      url: url,
      mimeType: mimeType,
    ),
  );

  @override
  Future<Result<void>> deletePhoto({
    required String businessId,
    required String photoId,
  }) => _capture(
    () => _remote.deletePhoto(businessId: businessId, photoId: photoId),
  );

  @override
  Future<Result<ManagedBusiness>> reorderPhotos({
    required String businessId,
    required List<String> orderedPhotoIds,
  }) => _capture(
    () => _remote.reorderPhotos(
      businessId: businessId,
      orderedPhotoIds: orderedPhotoIds,
    ),
  );
}
