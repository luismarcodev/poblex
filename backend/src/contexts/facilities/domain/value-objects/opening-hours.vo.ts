import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type DayKey = 'mon' | 'tue' | 'wed' | 'thu' | 'fri' | 'sat' | 'sun';

export interface DayRange {
  open: string; // "HH:mm"
  close: string; // "HH:mm"
}

export type OpeningHoursProps = Record<DayKey, DayRange | null>;

const DAY_KEYS: readonly DayKey[] = [
  'mon',
  'tue',
  'wed',
  'thu',
  'fri',
  'sat',
  'sun',
];

const TIME_REGEX = /^([01]\d|2[0-3]):[0-5]\d$/;

// Horario semanal de una instalación: un único rango por día (o null si ese
// día está cerrada). Las horas se interpretan como hora UTC del servidor, NO
// como hora local de Madrid — el resto del backend tampoco hace conversión
// de zona horaria en ningún sitio (eventos y alertas guardan UTC puro y es
// el cliente Flutter quien hace `.toLocal()`), así que esto sigue el mismo
// criterio en vez de inventar uno nuevo solo para este módulo. Si algún día
// hace falta que "09:00" signifique realmente las 9 de la mañana en Madrid
// durante el cambio de hora, hace falta una librería de zonas horarias
// (`date-fns-tz` o similar) — no está aquí todavía, y no se ha fingido que sí.
export class OpeningHours {
  private constructor(private readonly days: OpeningHoursProps) {}

  static create(value: unknown): OpeningHours {
    if (typeof value !== 'object' || value === null || Array.isArray(value)) {
      throw new ValidationError(
        'OpeningHours must be an object keyed by weekday (mon..sun)',
      );
    }
    const raw = value as Record<string, unknown>;
    const days = {} as OpeningHoursProps;
    for (const key of DAY_KEYS) {
      const entry = raw[key];
      if (entry === null || entry === undefined) {
        days[key] = null;
        continue;
      }
      const range = entry as Partial<DayRange>;
      if (
        typeof range.open !== 'string' ||
        typeof range.close !== 'string' ||
        !TIME_REGEX.test(range.open) ||
        !TIME_REGEX.test(range.close) ||
        range.open >= range.close
      ) {
        throw new ValidationError(
          `Invalid opening hours for "${key}": expected {open, close} as "HH:mm" with open < close, or null`,
        );
      }
      days[key] = { open: range.open, close: range.close };
    }
    return new OpeningHours(days);
  }

  rangeFor(day: DayKey): DayRange | null {
    return this.days[day];
  }

  toJSON(): OpeningHoursProps {
    return { ...this.days };
  }

  // getUTCDay(): 0=domingo..6=sábado. DAY_KEYS empieza en lunes, de ahí el
  // desplazamiento.
  static dayKeyFor(date: Date): DayKey {
    return DAY_KEYS[(date.getUTCDay() + 6) % 7];
  }
}
