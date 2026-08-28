import '../../../../core/result/result.dart';
import '../entities/survey.dart';

abstract interface class SurveyRepository {
  Future<Result<SurveyPage>> list({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  });

  Future<Result<Survey>> detail({
    required String id,
    required String municipalityId,
  });

  /// UNIQUE (survey_id, device_id) server-side: a second vote for the same
  /// survey from this device fails rather than replacing the first one.
  Future<Result<void>> vote({
    required String surveyId,
    required String optionId,
  });
}
