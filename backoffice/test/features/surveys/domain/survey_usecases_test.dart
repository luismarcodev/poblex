import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/surveys/domain/entities/managed_survey.dart';
import 'package:poblex_backoffice/features/surveys/domain/repositories/survey_repository.dart';
import 'package:poblex_backoffice/features/surveys/domain/usecases/survey_usecases.dart';

class FakeSurveyRepository implements SurveyRepository {
  int createCalls = 0;

  @override
  Future<Result<ManagedSurvey>> create(CreateSurveyInput input) async {
    createCalls++;
    return Success(_survey);
  }

  @override
  Future<Result<ManagedSurvey>> close(String id) => throw UnimplementedError();
  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();
  @override
  Future<Result<String>> exportResultsCsv(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<ManagedSurvey>> getDetail({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();
  @override
  Future<Result<ManagedSurveysPage>> getSurveys({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => throw UnimplementedError();
  @override
  Future<Result<ManagedSurvey>> setResultsVisibility(String id, bool visible) =>
      throw UnimplementedError();
}

void main() {
  test('rejects fewer than two options without writing', () async {
    final repository = FakeSurveyRepository();
    final result = await CreateSurvey(repository)(
      _input(options: const [SurveyLocalizedText(es: 'Una')]),
      now: DateTime.utc(2026, 8, 10),
    );

    expect(result, isA<Failure<ManagedSurvey>>());
    expect(repository.createCalls, 0);
  });

  test('rejects a closing instant in the past without writing', () async {
    final repository = FakeSurveyRepository();
    final result = await CreateSurvey(repository)(
      _input(closesAt: DateTime.utc(2026, 8, 9)),
      now: DateTime.utc(2026, 8, 10),
    );

    expect(result, isA<Failure<ManagedSurvey>>());
    expect(repository.createCalls, 0);
  });

  test('accepts a future bilingual survey', () async {
    final repository = FakeSurveyRepository();
    final result = await CreateSurvey(repository)(
      _input(),
      now: DateTime.utc(2026, 8, 10),
    );

    expect(result, isA<Success<ManagedSurvey>>());
    expect(repository.createCalls, 1);
  });
}

CreateSurveyInput _input({
  DateTime? closesAt,
  List<SurveyLocalizedText> options = const [
    SurveyLocalizedText(es: 'Una'),
    SurveyLocalizedText(es: 'Dos'),
  ],
}) => CreateSurveyInput(
  municipalityId: 'municipality-1',
  question: const SurveyLocalizedText(es: 'Pregunta'),
  closesAt: closesAt ?? DateTime.utc(2026, 9, 1),
  resultsVisible: false,
  options: options,
);

final _survey = ManagedSurvey(
  id: 'survey-1',
  municipalityId: 'municipality-1',
  question: const SurveyLocalizedText(es: 'Pregunta'),
  closesAt: DateTime.utc(2026, 9, 1),
  isOpen: true,
  binding: false,
  options: const [
    ManagedSurveyOption(
      id: 'one',
      label: SurveyLocalizedText(es: 'Una'),
      position: 0,
    ),
    ManagedSurveyOption(
      id: 'two',
      label: SurveyLocalizedText(es: 'Dos'),
      position: 1,
    ),
  ],
);
