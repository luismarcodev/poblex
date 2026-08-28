import '../../../../core/network/api_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/managed_survey.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/survey_remote_datasource.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  const SurveyRepositoryImpl(this._remote);

  final SurveyRemoteDataSource _remote;

  Future<Result<T>> _capture<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } catch (error) {
      return Failure(mapApiError(error));
    }
  }

  @override
  Future<Result<ManagedSurveysPage>> getSurveys({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => _capture(
    () => _remote.getSurveys(
      municipalityId: municipalityId,
      includeClosed: includeClosed,
      cursor: cursor,
    ),
  );

  @override
  Future<Result<ManagedSurvey>> getDetail({
    required String id,
    required String municipalityId,
  }) =>
      _capture(() => _remote.getDetail(id: id, municipalityId: municipalityId));

  @override
  Future<Result<ManagedSurvey>> create(CreateSurveyInput input) =>
      _capture(() => _remote.create(input));

  @override
  Future<Result<ManagedSurvey>> close(String id) =>
      _capture(() => _remote.close(id));

  @override
  Future<Result<ManagedSurvey>> setResultsVisibility(String id, bool visible) =>
      _capture(() => _remote.setResultsVisibility(id, visible));

  @override
  Future<Result<void>> delete(String id) => _capture(() => _remote.delete(id));

  @override
  Future<Result<String>> exportResultsCsv(String id) =>
      _capture(() => _remote.exportResultsCsv(id));
}
