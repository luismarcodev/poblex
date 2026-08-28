import '../../../../core/errors/app_failure.dart';
import '../../../../core/result/result.dart';
import '../entities/managed_survey.dart';
import '../repositories/survey_repository.dart';

class GetManagedSurveys {
  const GetManagedSurveys(this._repository);
  final SurveyRepository _repository;

  Future<Result<ManagedSurveysPage>> call({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => _repository.getSurveys(
    municipalityId: municipalityId,
    includeClosed: includeClosed,
    cursor: cursor,
  );
}

class GetManagedSurveyDetail {
  const GetManagedSurveyDetail(this._repository);
  final SurveyRepository _repository;

  Future<Result<ManagedSurvey>> call({
    required String id,
    required String municipalityId,
  }) => _repository.getDetail(id: id, municipalityId: municipalityId);
}

class CreateSurvey {
  const CreateSurvey(this._repository);
  final SurveyRepository _repository;

  Future<Result<ManagedSurvey>> call(CreateSurveyInput input, {DateTime? now}) {
    if (input.municipalityId.trim().isEmpty ||
        input.question.es.trim().isEmpty ||
        input.options.any((option) => option.es.trim().isEmpty)) {
      return Future.value(
        const Failure(ValidationFailure(message: 'survey_required_fields')),
      );
    }
    if (input.options.length < 2) {
      return Future.value(
        const Failure(ValidationFailure(message: 'survey_minimum_options')),
      );
    }
    if (!input.closesAt.isAfter(now ?? DateTime.now())) {
      return Future.value(
        const Failure(ValidationFailure(message: 'survey_future_closing')),
      );
    }
    return _repository.create(input);
  }
}

class CloseSurvey {
  const CloseSurvey(this._repository);
  final SurveyRepository _repository;
  Future<Result<ManagedSurvey>> call(String id) => _repository.close(id);
}

class SetSurveyResultsVisibility {
  const SetSurveyResultsVisibility(this._repository);
  final SurveyRepository _repository;
  Future<Result<ManagedSurvey>> call(String id, bool visible) =>
      _repository.setResultsVisibility(id, visible);
}

class DeleteSurvey {
  const DeleteSurvey(this._repository);
  final SurveyRepository _repository;
  Future<Result<void>> call(String id) => _repository.delete(id);
}

class ExportSurveyResultsCsv {
  const ExportSurveyResultsCsv(this._repository);
  final SurveyRepository _repository;
  Future<Result<String>> call(String id) => _repository.exportResultsCsv(id);
}
