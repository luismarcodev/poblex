import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type FieldTypeValue = 'text' | 'number' | 'select' | 'date' | 'boolean';

const TYPES: readonly FieldTypeValue[] = [
  'text',
  'number',
  'select',
  'date',
  'boolean',
];

// Motor genérico configurable: los formularios no se programan uno a uno, se
// describen con estos cinco tipos de campo.
export class FormFieldType {
  private constructor(readonly value: FieldTypeValue) {}

  static create(value: string): FormFieldType {
    const normalized = value.trim().toLowerCase();
    if (!TYPES.includes(normalized as FieldTypeValue)) {
      throw new ValidationError(
        `Invalid FormFieldType: "${value}" (expected ${TYPES.join(', ')})`,
      );
    }
    return new FormFieldType(normalized as FieldTypeValue);
  }

  get requiresOptions(): boolean {
    return this.value === 'select';
  }

  // Los valores llegan serializados como texto; el tipo gobierna cómo se
  // interpretan. Devuelve el motivo del rechazo, o null si el valor vale.
  rejectionReason(raw: string): string | null {
    switch (this.value) {
      case 'number':
        return Number.isFinite(Number(raw)) ? null : 'expected a number';
      case 'date':
        return Number.isNaN(new Date(raw).getTime())
          ? 'expected an ISO date'
          : null;
      case 'boolean':
        return raw === 'true' || raw === 'false'
          ? null
          : 'expected "true" or "false"';
      case 'text':
      case 'select':
        return null;
    }
  }
}
