import '../../../../core/network/dio_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/survey.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/survey_remote_datasource.dart';
import '../mappers/survey_mapper.dart';
import '../models/survey_model.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  const SurveyRepositoryImpl(this._remote);
  final SurveyRemoteDataSource _remote;

  @override
  Future<Result<SurveyPage>> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) async {
    try {
      final SurveyPageModel page = await _remote.list(
        municipalityId: municipalityId,
        includeClosed: includeClosed,
        cursor: cursor,
      );
      return Success<SurveyPage>(
        SurveyPage(
          items: page.items.map(SurveyMapper.toDomain).toList(growable: false),
          nextCursor: page.nextCursor,
        ),
      );
    } on Object catch (error) {
      return Failed<SurveyPage>(mapDioError(error));
    }
  }

  @override
  Future<Result<Survey>> detail({
    required String id,
    required String municipalityId,
  }) async {
    try {
      return Success<Survey>(
        SurveyMapper.toDomain(
          await _remote.detail(id: id, municipalityId: municipalityId),
        ),
      );
    } on Object catch (error) {
      return Failed<Survey>(mapDioError(error));
    }
  }

  @override
  Future<Result<void>> vote({
    required String surveyId,
    required String optionId,
  }) async {
    try {
      await _remote.vote(surveyId: surveyId, optionId: optionId);
      return const Success<void>(null);
    } on Object catch (error) {
      return Failed<void>(mapDioError(error));
    }
  }
}
