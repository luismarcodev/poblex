import '../../../../core/result/result.dart';
import '../entities/survey.dart';
import '../repositories/survey_repository.dart';

class GetSurveys {
  const GetSurveys(this._repository);
  final SurveyRepository _repository;

  Future<Result<SurveyPage>> call({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => _repository.list(
    municipalityId: municipalityId,
    includeClosed: includeClosed,
    cursor: cursor,
  );
}

class GetSurveyDetail {
  const GetSurveyDetail(this._repository);
  final SurveyRepository _repository;

  Future<Result<Survey>> call({
    required String id,
    required String municipalityId,
  }) => _repository.detail(id: id, municipalityId: municipalityId);
}

class VoteSurvey {
  const VoteSurvey(this._repository);
  final SurveyRepository _repository;

  Future<Result<void>> call({
    required String surveyId,
    required String optionId,
  }) => _repository.vote(surveyId: surveyId, optionId: optionId);
}
