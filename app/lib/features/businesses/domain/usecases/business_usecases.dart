import '../../../../core/result/result.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetBusinesses {
  const GetBusinesses(this._repository);
  final BusinessRepository _repository;

  Future<Result<BusinessPage>> call({
    required String municipalityId,
    String? category,
    String? cursor,
  }) => _repository.list(
    municipalityId: municipalityId,
    category: category,
    cursor: cursor,
  );
}

class GetBusinessCategories {
  const GetBusinessCategories(this._repository);
  final BusinessRepository _repository;

  Future<Result<List<String>>> call(String municipalityId) =>
      _repository.categories(municipalityId);
}

class GetBusinessDetail {
  const GetBusinessDetail(this._repository);
  final BusinessRepository _repository;

  Future<Result<MunicipalBusiness>> call({
    required String id,
    required String municipalityId,
  }) => _repository.detail(id: id, municipalityId: municipalityId);
}
