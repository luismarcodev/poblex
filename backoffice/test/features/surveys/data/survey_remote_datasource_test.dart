import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/surveys/data/datasources/survey_remote_datasource.dart';
import 'package:poblex_backoffice/features/surveys/domain/entities/managed_survey.dart';

void main() {
  test(
    'uses cursor pagination and the public municipality-scoped list',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      late RequestOptions captured;
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'items': [_response],
                  'nextCursor': 'next-page',
                },
              ),
            );
          },
        ),
      );

      final page = await SurveyRemoteDataSource(dio).getSurveys(
        municipalityId: 'municipality-1',
        includeClosed: true,
        cursor: 'current-page',
      );

      expect(captured.path, '/surveys');
      expect(captured.queryParameters, {
        'municipalityId': 'municipality-1',
        'includeClosed': true,
        'limit': 20,
        'cursor': 'current-page',
      });
      expect(page.items.single.id, 'survey-1');
      expect(page.nextCursor, 'next-page');
    },
  );

  test('serializes creation according to the admin contract', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 201,
              data: _response,
            ),
          );
        },
      ),
    );

    await SurveyRemoteDataSource(dio).create(
      CreateSurveyInput(
        municipalityId: 'municipality-1',
        question: const SurveyLocalizedText(es: 'Pregunta', va: 'Pregunta va'),
        closesAt: DateTime.utc(2026, 9, 1, 10),
        resultsVisible: false,
        options: const [
          SurveyLocalizedText(es: 'Uno', va: 'U'),
          SurveyLocalizedText(es: 'Dos'),
        ],
      ),
    );

    expect(captured.path, '/admin/surveys');
    expect(captured.method, 'POST');
    expect(captured.data['municipalityId'], 'municipality-1');
    expect(captured.data['closesAt'], '2026-09-01T10:00:00.000Z');
    expect(captured.data['resultsVisible'], isFalse);
    expect(captured.data['options'], [
      {'es': 'Uno', 'va': 'U'},
      {'es': 'Dos'},
    ]);
  });

  test('requests the protected CSV endpoint as plain text', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<String>(
              requestOptions: options,
              statusCode: 200,
              data: 'opcion_es,votos\nUno,3',
            ),
          );
        },
      ),
    );

    final csv = await SurveyRemoteDataSource(dio).exportResultsCsv('survey-1');

    expect(captured.path, '/admin/surveys/survey-1/results.csv');
    expect(captured.responseType, ResponseType.plain);
    expect(csv, contains('Uno,3'));
  });
}

final Map<String, dynamic> _response = {
  'id': 'survey-1',
  'municipalityId': 'municipality-1',
  'question': {'es': 'Pregunta', 'va': 'Pregunta va'},
  'closesAt': '2026-09-01T10:00:00.000Z',
  'isOpen': true,
  'binding': false,
  'options': [
    {
      'id': 'option-1',
      'label': {'es': 'Uno', 'va': 'U'},
      'position': 0,
      'votes': null,
    },
    {
      'id': 'option-2',
      'label': {'es': 'Dos'},
      'position': 1,
      'votes': null,
    },
  ],
  'votedOptionId': null,
};
