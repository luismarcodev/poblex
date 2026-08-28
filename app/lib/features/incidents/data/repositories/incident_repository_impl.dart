import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/incident.dart';
import '../../domain/repositories/incident_repository.dart';
import '../datasources/incident_remote_datasource.dart';
import '../mappers/incident_mapper.dart';
import '../models/incident_model.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  const IncidentRepositoryImpl(this._remote);
  final IncidentRemoteDataSource _remote;

  @override
  Future<Result<Incident>> report({
    required String municipalityId,
    required String category,
    required String description,
    double? lat,
    double? lng,
  }) async {
    try {
      return Success<Incident>(
        IncidentMapper.toDomain(
          await _remote.report(
            municipalityId: municipalityId,
            category: category,
            description: description,
            lat: lat,
            lng: lng,
          ),
        ),
      );
    } on Object catch (error) {
      return Failed<Incident>(mapDioError(error));
    }
  }

  @override
  Future<Result<Incident>> uploadPhoto({
    required String incidentId,
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      return Success<Incident>(
        IncidentMapper.toDomain(
          await _remote.uploadPhoto(
            incidentId: incidentId,
            bytes: bytes,
            filename: filename,
          ),
        ),
      );
    } on Object catch (error) {
      return Failed<Incident>(mapDioError(error));
    }
  }

  @override
  Future<Result<IncidentPage>> listMine({String? cursor}) async {
    try {
      final IncidentPageModel page = await _remote.listMine(cursor: cursor);
      return Success<IncidentPage>(
        IncidentPage(
          items: page.items
              .map(IncidentMapper.toDomain)
              .toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<IncidentPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<IncidentDetail>> detail(String id) async {
    try {
      return Success<IncidentDetail>(
        IncidentMapper.detailToDomain(await _remote.detail(id)),
      );
    } on Object catch (error) {
      return Failed<IncidentDetail>(mapDioError(error));
    }
  }
}
