import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/forms/data/models/managed_form_model.dart';
import 'package:poblex_backoffice/features/forms/domain/entities/managed_form.dart';

void main() {
  test('maps and orders configurable fields from the API', () {
    final form = ManagedFormModel.fromJson(_response).entity;

    expect(form.title.es, 'Inscripción paellas');
    expect(form.title.va, 'Inscripció paelles');
    expect(form.deadline, DateTime.utc(2026, 9, 1, 12));
    expect(form.fields.map((field) => field.key), ['name', 'diners']);
    expect(form.fields.last.type, ManagedFormFieldType.number);
  });
}

final Map<String, dynamic> _response = {
  'id': 'form-1',
  'municipalityId': 'municipality-1',
  'title': {'es': 'Inscripción paellas', 'va': 'Inscripció paelles'},
  'description': {'es': 'Datos de la inscripción'},
  'deadline': '2026-09-01T12:00:00.000Z',
  'isOpen': true,
  'alreadySubmitted': false,
  'fields': [
    {
      'id': 'field-2',
      'key': 'diners',
      'label': {'es': 'Comensales'},
      'type': 'number',
      'required': true,
      'options': <String>[],
      'position': 1,
    },
    {
      'id': 'field-1',
      'key': 'name',
      'label': {'es': 'Nombre'},
      'type': 'text',
      'required': true,
      'options': <String>[],
      'position': 0,
    },
  ],
};
