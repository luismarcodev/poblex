import { ValidationError } from '../errors/common-errors';

export type LocaleCode = 'es' | 'va';

interface LocalizedTextProps {
  es?: string;
  va?: string;
}

interface ResolvedText {
  text: string;
  isFallback: boolean;
}

// Contenido bilingüe {es, va}. Fallback obligatorio: si falta un idioma,
// resolve() devuelve el disponible marcando isFallback — nunca un hueco vacío.
export class LocalizedText {
  private constructor(private readonly values: LocalizedTextProps) {}

  static create(values: LocalizedTextProps): LocalizedText {
    if (!values.es && !values.va) {
      throw new ValidationError(
        'LocalizedText requires at least one language (es or va)',
      );
    }
    return new LocalizedText({ es: values.es, va: values.va });
  }

  resolve(locale: LocaleCode): ResolvedText {
    const primary = this.values[locale];
    if (primary) return { text: primary, isFallback: false };

    const fallbackLocale: LocaleCode = locale === 'es' ? 'va' : 'es';
    const fallback = this.values[fallbackLocale];
    if (fallback) return { text: fallback, isFallback: true };

    throw new ValidationError(
      'LocalizedText has no value for any known locale',
    );
  }

  toJSON(): LocalizedTextProps {
    return { ...this.values };
  }
}
