import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { FormFieldType } from '../value-objects/form-field-type.vo';
import { Form, FormField, FormProps } from './form.entity';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';

function field(
  id: string,
  key: string,
  type: string,
  required = false,
  options: string[] = [],
): FormField {
  return FormField.create({
    id,
    key,
    label: LocalizedText.create({ es: key }),
    type: FormFieldType.create(type),
    required,
    options,
    position: 0,
  });
}

function buildProps(overrides: Partial<FormProps> = {}): FormProps {
  return {
    id: 'form-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    title: LocalizedText.create({ es: 'Censo de paellas' }),
    description: LocalizedText.create({ es: 'Apúntate' }),
    deadline: new Date('2026-08-01T00:00:00Z'),
    fields: [
      field('f1', 'nombre', 'text', true),
      field('f2', 'comensales', 'number'),
      field('f3', 'turno', 'select', false, ['mañana', 'tarde']),
    ],
    ...overrides,
  };
}

describe('Form', () => {
  it('rejects a form with no fields', () => {
    expect(() => Form.create(buildProps({ fields: [] }))).toThrow(
      ValidationError,
    );
  });

  it('rejects duplicated field keys', () => {
    expect(() =>
      Form.create(
        buildProps({
          fields: [
            field('f1', 'nombre', 'text'),
            field('f2', 'nombre', 'text'),
          ],
        }),
      ),
    ).toThrow(ValidationError);
  });

  it('rejects a select field with no options', () => {
    expect(() => field('f1', 'turno', 'select')).toThrow(ValidationError);
  });

  it('is open when it has no deadline', () => {
    const form = Form.create(buildProps({ deadline: null }));

    expect(form.isOpenAt(new Date('2050-01-01T00:00:00Z'))).toBe(true);
  });

  it('closes once the deadline has passed', () => {
    const form = Form.create(buildProps());

    expect(form.isOpenAt(new Date('2026-07-31T23:59:00Z'))).toBe(true);
    expect(form.isOpenAt(new Date('2026-08-01T00:00:01Z'))).toBe(false);
  });

  describe('validateSubmission', () => {
    it('accepts a submission that fills every rule', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: 'Luis' },
        { fieldId: 'f2', value: '4' },
        { fieldId: 'f3', value: 'tarde' },
      ]);

      expect(problems).toEqual([]);
    });

    it('reports a missing required field', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([{ fieldId: 'f2', value: '4' }]);

      expect(problems).toEqual(['Field "nombre" is required']);
    });

    // Un campo obligatorio con espacios en blanco sigue estando vacío.
    it('treats a blank value as missing', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: '   ' },
      ]);

      expect(problems).toEqual(['Field "nombre" is required']);
    });

    it('allows an optional field to be left out', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: 'Luis' },
      ]);

      expect(problems).toEqual([]);
    });

    it('rejects a non-numeric value in a number field', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: 'Luis' },
        { fieldId: 'f2', value: 'muchos' },
      ]);

      expect(problems).toEqual(['Field "comensales": expected a number']);
    });

    it('rejects a value outside the allowed options', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: 'Luis' },
        { fieldId: 'f3', value: 'madrugada' },
      ]);

      expect(problems).toEqual([
        'Field "turno": "madrugada" is not an allowed option',
      ]);
    });

    // Alguien inventando campos, o un envío de otro formulario.
    it('rejects answers to fields that do not exist', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: 'Luis' },
        { fieldId: 'intruso', value: 'x' },
      ]);

      expect(problems).toEqual(['Unknown field id: intruso']);
    });

    it('rejects duplicate answers for the same field', () => {
      const form = Form.create(buildProps());

      const problems = form.validateSubmission([
        { fieldId: 'f1', value: 'Luis' },
        { fieldId: 'f1', value: 'María' },
      ]);

      expect(problems).toEqual(['Duplicate answer for field id: f1']);
    });

    it('validates dates and booleans by type', () => {
      const form = Form.create(
        buildProps({
          fields: [
            field('d', 'fecha', 'date'),
            field('b', 'acepta', 'boolean'),
          ],
        }),
      );

      expect(
        form.validateSubmission([
          { fieldId: 'd', value: '2026-08-01' },
          { fieldId: 'b', value: 'true' },
        ]),
      ).toEqual([]);

      expect(
        form.validateSubmission([
          { fieldId: 'd', value: 'el martes' },
          { fieldId: 'b', value: 'sí' },
        ]),
      ).toEqual([
        'Field "fecha": expected an ISO date',
        'Field "acepta": expected "true" or "false"',
      ]);
    });
  });
});
