import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type SeverityLevel = 'amarillo' | 'naranja' | 'rojo';

const LEVELS: readonly SeverityLevel[] = ['amarillo', 'naranja', 'rojo'];

// Severidad de aviso meteorológico, con los tres niveles de AEMET. Un valor
// inválido no llega a existir.
export class AlertSeverity {
  private constructor(readonly value: SeverityLevel) {}

  static create(value: string): AlertSeverity {
    const normalized = value.trim().toLowerCase();
    if (!LEVELS.includes(normalized as SeverityLevel)) {
      throw new ValidationError(
        `Invalid AlertSeverity: "${value}" (expected amarillo, naranja or rojo)`,
      );
    }
    return new AlertSeverity(normalized as SeverityLevel);
  }

  // Regla de negocio, no de infraestructura: una alerta roja notifica SIEMPRE,
  // aunque el vecino tenga las alertas silenciadas. Vive en el dominio.
  get forcesNotification(): boolean {
    return this.value === 'rojo';
  }

  isAtLeast(other: AlertSeverity): boolean {
    return LEVELS.indexOf(this.value) >= LEVELS.indexOf(other.value);
  }

  equals(other: AlertSeverity): boolean {
    return this.value === other.value;
  }
}
