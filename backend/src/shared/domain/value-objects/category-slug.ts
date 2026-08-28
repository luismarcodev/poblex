import { ValidationError } from '../errors/common-errors';

// Las categorías de contenido (noticias, eventos, incidencias) son etiquetas
// ABIERTAS, sin lista cerrada todavía: se valida el FORMATO (slug), no un
// enum de valores fijos. Regla común a todos los contextos, definida una vez.
const CATEGORY_SLUG_REGEX = /^[a-z0-9]+(-[a-z0-9]+)*$/;

export function normalizeCategorySlug(value: string, label: string): string {
  const trimmed = value.trim().toLowerCase();
  if (!CATEGORY_SLUG_REGEX.test(trimmed)) {
    throw new ValidationError(
      `Invalid ${label}: "${value}" (expected lowercase slug, e.g. "general", "cultural")`,
    );
  }
  return trimmed;
}
