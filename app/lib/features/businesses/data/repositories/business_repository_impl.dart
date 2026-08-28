import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/business_remote_datasource.dart';
import '../mappers/business_mapper.dart';
import '../models/business_model.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  const BusinessRepositoryImpl(this._remote);
  final BusinessRemoteDataSource _remote;

  @override
  Future<Result<BusinessPage>> list({
    required String municipalityId,
    String? category,
    String? cursor,
  }) async {
    try {
      final BusinessPageModel page = await _remote.list(
        municipalityId: municipalityId,
        category: category,
        cursor: cursor,
      );
      return Success<BusinessPage>(
        BusinessPage(
          items: page.items
              .map(BusinessMapper.toDomain)
              .toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<BusinessPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<List<String>>> categories(String municipalityId) async {
    try {
      return Success<List<String>>(await _remote.categories(municipalityId));
    } on Object catch (error) {
      return Failed<List<String>>(mapDioError(error));
    }
  }

  @override
  Future<Result<MunicipalBusiness>> detail({
    required String id,
    required String municipalityId,
  }) async {
    try {
      return Success<MunicipalBusiness>(
        BusinessMapper.toDomain(
          await _remote.detail(id: id, municipalityId: municipalityId),
        ),
      );
    } on Object catch (error) {
      return Failed<MunicipalBusiness>(mapDioError(error));
    }
  }
}
