import '../../../../core/result/result.dart';
import '../entities/business.dart';

abstract interface class BusinessRepository {
  Future<Result<BusinessPage>> list({
    required String municipalityId,
    String? category,
    String? cursor,
  });

  Future<Result<List<String>>> categories(String municipalityId);

  Future<Result<MunicipalBusiness>> detail({
    required String id,
    required String municipalityId,
  });
}
