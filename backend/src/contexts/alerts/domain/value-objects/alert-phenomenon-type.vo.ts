import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type PhenomenonTypeKind =
  'incendio' | 'evacuacion' | 'meteorologico' | 'sanitario' | 'otro';

const TYPES: readonly PhenomenonTypeKind[] = [
  'incendio',
  'evacuacion',
  'meteorologico',
  'sanitario',
  'otro',
];

// Clasificación por tipo de fenómeno, independiente de AlertSeverity: nunca
// la sustituye, se le añade. Un incendio y una inundación pueden ambos ser
// severidad roja; esto es lo que las distingue en icono y etiqueta sin tocar
// color/barra/severidad, que quedan bloqueados a la paleta AEMET.
export class AlertPhenomenonType {
  private constructor(readonly value: PhenomenonTypeKind) {}

  static create(value: string): AlertPhenomenonType {
    const normalized = value.trim().toLowerCase();
    if (!TYPES.includes(normalized as PhenomenonTypeKind)) {
      throw new ValidationError(
        `Invalid AlertPhenomenonType: "${value}" (expected ${TYPES.join(', ')})`,
      );
    }
    return new AlertPhenomenonType(normalized as PhenomenonTypeKind);
  }

  // La sincronización con AEMET solo trae fenómenos meteorológicos (avisos de
  // lluvia, viento, etc.) — nunca puede autodeclararse incendio.
  static meteorologico(): AlertPhenomenonType {
    return new AlertPhenomenonType('meteorologico');
  }

  get isFireOrEvacuation(): boolean {
    return this.value === 'incendio' || this.value === 'evacuacion';
  }
}
