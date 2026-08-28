import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/surveys/data/models/managed_survey_model.dart';

void main() {
  test('parses bilingual content, nullable votes and option order', () {
    final survey = ManagedSurveyModel.fromJson({
      'id': 'survey-1',
      'municipalityId': 'municipality-1',
      'question': {'es': '¿Qué prefieres?', 'va': 'Què prefereixes?'},
      'closesAt': '2026-09-01T10:00:00.000Z',
      'isOpen': true,
      'binding': false,
      'options': [
        {
          'id': 'option-2',
          'label': {'es': 'Dos'},
          'position': 2,
          'votes': null,
        },
        {
          'id': 'option-1',
          'label': {'es': 'Uno', 'va': 'U'},
          'position': 1,
          'votes': null,
        },
      ],
    }).entity;

    expect(survey.question.va, 'Què prefereixes?');
    expect(survey.options.map((option) => option.id), ['option-1', 'option-2']);
    expect(survey.resultsAvailable, isFalse);
    expect(survey.binding, isFalse);
  });
}
