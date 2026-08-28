import '../../../../core/result/result.dart';
import '../entities/managed_survey.dart';

abstract interface class SurveyRepository {
  Future<Result<ManagedSurveysPage>> getSurveys({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  });

  Future<Result<ManagedSurvey>> getDetail({
    required String id,
    required String municipalityId,
  });

  Future<Result<ManagedSurvey>> create(CreateSurveyInput input);
  Future<Result<ManagedSurvey>> close(String id);
  Future<Result<ManagedSurvey>> setResultsVisibility(String id, bool visible);
  Future<Result<void>> delete(String id);
  Future<Result<String>> exportResultsCsv(String id);
}
