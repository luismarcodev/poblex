import { normalizeCategorySlug } from '../../../../shared/domain/value-objects/category-slug';

// Etiqueta abierta ("general", "sanitaria", ...) — el CLAUDE.md la describe
// como categoría abierta, sin lista cerrada todavía (pendiente de decisión
// de producto). El formato de slug lo valida la regla compartida.
export class NewsCategory {
  private constructor(readonly value: string) {}

  static create(value: string): NewsCategory {
    return new NewsCategory(normalizeCategorySlug(value, 'NewsCategory'));
  }

  equals(other: NewsCategory): boolean {
    return this.value === other.value;
  }
}
