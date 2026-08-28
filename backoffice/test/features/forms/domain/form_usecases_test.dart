import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/core/errors/app_failure.dart';
import 'package:poblex_backoffice/core/result/result.dart';
import 'package:poblex_backoffice/features/forms/domain/entities/managed_form.dart';
import 'package:poblex_backoffice/features/forms/domain/repositories/form_repository.dart';
import 'package:poblex_backoffice/features/forms/domain/usecases/form_usecases.dart';

class _Repository implements FormRepository {
  int creates = 0;
  @override
  Future<Result<ManagedForm>> create(CreateFormInput input) async {
    creates++;
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> delete(String id) => throw UnimplementedError();
  @override
  Future<Result<String>> exportSubmissionsCsv(String id) =>
      throw UnimplementedError();
  @override
  Future<Result<ManagedForm>> getDetail({
    required String id,
    required String municipalityId,
  }) => throw UnimplementedError();
  @override
  Future<Result<ManagedFormsPage>> getForms({
    required String municipalityId,
    required bool includeClosed,
    String? cursor,
  }) => throw UnimplementedError();
}

void main() {
  test(
    'rejects duplicate field keys before accessing the repository',
    () async {
      final repository = _Repository();
      final result = await CreateManagedForm(repository)(
        _input(fields: const [_textField, _textField]),
        now: DateTime.utc(2026, 8, 1),
      );
      expect(result, isA<Failure<ManagedForm>>());
      expect((result as Failure<ManagedForm>).error, isA<ValidationFailure>());
      expect(repository.creates, 0);
    },
  );

  test('requires options for a select field', () async {
    final repository = _Repository();
    final result = await CreateManagedForm(repository)(
      _input(
        fields: const [
          FormFieldDraft(
            key: 'meal',
            label: FormLocalizedText(es: 'Menú'),
            type: ManagedFormFieldType.select,
            required: true,
          ),
        ],
      ),
      now: DateTime.utc(2026, 8, 1),
    );
    expect(result, isA<Failure<ManagedForm>>());
    expect(repository.creates, 0);
  });
}

CreateFormInput _input({required List<FormFieldDraft> fields}) =>
    CreateFormInput(
      municipalityId: 'municipality-1',
      title: const FormLocalizedText(es: 'Formulario'),
      description: const FormLocalizedText(es: 'Descripción'),
      deadline: DateTime.utc(2026, 9, 1),
      fields: fields,
    );

const _textField = FormFieldDraft(
  key: 'name',
  label: FormLocalizedText(es: 'Nombre'),
  type: ManagedFormFieldType.text,
  required: true,
);
