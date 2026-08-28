import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/forms/data/datasources/form_remote_datasource.dart';
import 'package:poblex_backoffice/features/forms/domain/entities/managed_form.dart';

void main() {
  test('uses municipality-scoped cursor pagination', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: {
                'items': [_response],
                'nextCursor': 'next-page',
              },
            ),
          );
        },
      ),
    );

    final page = await FormRemoteDataSource(dio).getForms(
      municipalityId: 'municipality-1',
      includeClosed: true,
      cursor: 'current-page',
    );

    expect(captured.path, '/forms');
    expect(captured.queryParameters, {
      'municipalityId': 'municipality-1',
      'includeClosed': true,
      'limit': 20,
      'cursor': 'current-page',
    });
    expect(page.items.single.id, 'form-1');
  });

  test('serializes field order and optional deadline on creation', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              data: _response,
            ),
          );
        },
      ),
    );

    await FormRemoteDataSource(dio).create(
      CreateFormInput(
        municipalityId: 'municipality-1',
        title: const FormLocalizedText(es: 'Formulario'),
        description: const FormLocalizedText(es: 'Descripción'),
        deadline: DateTime.utc(2026, 9, 1, 12),
        fields: const [
          FormFieldDraft(
            key: 'meal',
            label: FormLocalizedText(es: 'Menú'),
            type: ManagedFormFieldType.select,
            required: true,
            options: ['Carne', 'Vegetariano'],
          ),
        ],
      ),
    );

    expect(captured.path, '/admin/forms');
    expect(captured.method, 'POST');
    expect(captured.data['deadline'], '2026-09-01T12:00:00.000Z');
    expect(captured.data['fields'], [
      {
        'key': 'meal',
        'label': {'es': 'Menú'},
        'type': 'select',
        'required': true,
        'options': ['Carne', 'Vegetariano'],
      },
    ]);
  });

  test('requests the protected submissions CSV as plain text', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
    late RequestOptions captured;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.resolve(
            Response<String>(
              requestOptions: options,
              data: 'enviado_en,name\n2026-08-10,Luis',
            ),
          );
        },
      ),
    );

    final csv = await FormRemoteDataSource(dio).exportSubmissionsCsv('form-1');
    expect(captured.path, '/admin/forms/form-1/submissions.csv');
    expect(captured.responseType, ResponseType.plain);
    expect(csv, contains('Luis'));
  });
}

final Map<String, dynamic> _response = {
  'id': 'form-1',
  'municipalityId': 'municipality-1',
  'title': {'es': 'Formulario'},
  'description': {'es': 'Descripción'},
  'deadline': '2026-09-01T12:00:00.000Z',
  'isOpen': true,
  'alreadySubmitted': false,
  'fields': [
    {
      'id': 'field-1',
      'key': 'meal',
      'label': {'es': 'Menú'},
      'type': 'select',
      'required': true,
      'options': ['Carne', 'Vegetariano'],
      'position': 0,
    },
  ],
};
