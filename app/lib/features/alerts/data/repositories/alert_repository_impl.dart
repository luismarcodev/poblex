import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_remote_datasource.dart';
import '../mappers/alert_mapper.dart';
import '../models/alert_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  const AlertRepositoryImpl(this._remote);
  final AlertRemoteDataSource _remote;

  @override
  Future<Result<AlertPage>> list({
    required String municipalityId,
    required bool includeExpired,
    String? cursor,
  }) async {
    try {
      final AlertPageModel page = await _remote.list(
        municipalityId: municipalityId,
        includeExpired: includeExpired,
        cursor: cursor,
      );
      return Success<AlertPage>(
        AlertPage(
          items: page.items.map(AlertMapper.toDomain).toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<AlertPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<MunicipalAlert>> detail({
    required String id,
    required String municipalityId,
  }) async {
    try {
      return Success<MunicipalAlert>(
        AlertMapper.toDomain(
          await _remote.detail(id: id, municipalityId: municipalityId),
        ),
      );
    } on Object catch (error) {
      return Failed<MunicipalAlert>(mapDioError(error));
    }
  }
}
