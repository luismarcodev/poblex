import { ValidationError } from '../errors/common-errors';
import { LocalizedText } from './localized-text';

describe('LocalizedText', () => {
  it('rejects a text with no language at all', () => {
    expect(() => LocalizedText.create({})).toThrow(ValidationError);
  });

  it('resolves the requested language when present', () => {
    const text = LocalizedText.create({ es: 'Hola', va: 'Hola' });

    expect(text.resolve('es')).toEqual({ text: 'Hola', isFallback: false });
  });

  // Fallback obligatorio: jamás un hueco vacío ni "null".
  it('falls back to the other language and flags it', () => {
    const text = LocalizedText.create({ es: 'Corte de agua' });

    expect(text.resolve('va')).toEqual({
      text: 'Corte de agua',
      isFallback: true,
    });
  });

  it('serialises both languages, keeping the missing one undefined', () => {
    const text = LocalizedText.create({ va: 'Tall d’aigua' });

    expect(text.toJSON()).toEqual({ es: undefined, va: 'Tall d’aigua' });
  });
});
