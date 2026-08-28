import { normalizeCategorySlug } from '../../../../shared/domain/value-objects/category-slug';

// Etiqueta abierta ("bar", "alimentacion", ...), igual que NewsCategory: el
// gestor la escribe libremente desde el backoffice, sin lista cerrada.
export class BusinessCategory {
  private constructor(readonly value: string) {}

  static create(value: string): BusinessCategory {
    return new BusinessCategory(
      normalizeCategorySlug(value, 'BusinessCategory'),
    );
  }

  equals(other: BusinessCategory): boolean {
    return this.value === other.value;
  }
}
