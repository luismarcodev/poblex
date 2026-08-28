import { normalizeCategorySlug } from '../../../../shared/domain/value-objects/category-slug';

// Etiqueta abierta ("cultural", "deportivo", "fiestas", ...).
export class EventCategory {
  private constructor(readonly value: string) {}

  static create(value: string): EventCategory {
    return new EventCategory(normalizeCategorySlug(value, 'EventCategory'));
  }

  equals(other: EventCategory): boolean {
    return this.value === other.value;
  }
}
