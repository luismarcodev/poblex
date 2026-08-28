import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { AlertSeverity } from '../value-objects/alert-severity.vo';

// Aviso meteorológico tal y como lo entiende el DOMINIO. El dominio no sabe
// que AEMET existe: solo sabe que alguien le proporciona avisos por zona.
export interface WeatherWarning {
  // Identificador estable en el proveedor — base de la deduplicación.
  externalId: string;
  severity: AlertSeverity;
  phenomenon: string;
  body: LocalizedText;
  startAt: Date;
  endAt: Date | null;
}

export interface WeatherWarningProviderPort {
  fetchWarningsForZone(zoneCode: string): Promise<WeatherWarning[]>;
}

export const WEATHER_WARNING_PROVIDER_PORT = Symbol(
  'WEATHER_WARNING_PROVIDER_PORT',
);
