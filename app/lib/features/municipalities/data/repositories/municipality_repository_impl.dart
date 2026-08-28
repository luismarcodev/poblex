import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/municipality.dart';
import '../../domain/repositories/municipality_repository.dart';
import '../datasources/municipality_remote_datasource.dart';
import '../models/municipality_model.dart';

class MunicipalityRepositoryImpl implements MunicipalityRepository {
  const MunicipalityRepositoryImpl(this._remote);

  final MunicipalityRemoteDataSource _remote;

  @override
  Future<Result<List<Municipality>>> listActive() async {
    try {
      final List<MunicipalityModel> models = await _remote.listActive();
      return Success<List<Municipality>>(
        models
            .map(
              (MunicipalityModel model) => Municipality(
                id: model.id,
                slug: model.slug,
                name: model.name,
                province: model.province,
                languages: model.languages,
                primaryColor: model.primaryColor,
                logoUrl: model.logoUrl,
              ),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return Failed<List<Municipality>>(mapDioError(error));
    }
  }
}
