import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { AlertSeverity } from '../../domain/value-objects/alert-severity.vo';
import type { WeatherWarning } from '../../domain/ports/weather-warning.port';

// Traducción del CAP de AEMET al aviso que entiende el dominio.
//
// Se hace con extracción por etiqueta en vez de con un parser XML completo:
// del documento solo interesan seis campos y añadir una dependencia de
// parseo XML por eso no se sostiene. Si algún día hiciera falta leer el CAP
// entero, esto se sustituye por un parser de verdad.
//
// AVISO: la estructura exacta del CAP de AEMET (nombres de parámetro y
// geocódigos) debe verificarse contra una respuesta REAL antes de dar la
// integración por buena en producción. Ver docs de AEMET OpenData.

const CAP_SEVERITY_FALLBACK: Record<string, string> = {
  Extreme: 'rojo',
  Severe: 'naranja',
  Moderate: 'amarillo',
};

function tagValue(xml: string, tag: string): string | null {
  const match = new RegExp(`<${tag}>([\\s\\S]*?)</${tag}>`).exec(xml);
  return match ? match[1].trim() : null;
}

function allBlocks(xml: string, tag: string): string[] {
  return [
    ...xml.matchAll(new RegExp(`<${tag}>([\\s\\S]*?)</${tag}>`, 'g')),
  ].map((match) => match[1]);
}

// <parameter><valueName>...</valueName><value>...</value></parameter>
function namedValue(
  xml: string,
  container: string,
  name: string,
): string | null {
  for (const block of allBlocks(xml, container)) {
    const valueName = tagValue(block, 'valueName');
    if (valueName && valueName.toLowerCase().includes(name.toLowerCase())) {
      return tagValue(block, 'value');
    }
  }
  return null;
}

function parseDate(value: string | null): Date | null {
  if (!value) return null;
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

// Un documento CAP puede llevar varios <info>, uno por idioma. El identificador
// y la zona son comunes; el texto cambia.
export function parseCapDocument(
  xml: string,
  zoneCode: string,
): WeatherWarning | null {
  const identifier = tagValue(xml, 'identifier');
  if (!identifier) return null;

  const infos = allBlocks(xml, 'info');
  if (infos.length === 0) return null;

  // Solo interesa el documento si cubre la zona pedida.
  const coversZone = infos.some(
    (info) => namedValue(info, 'geocode', 'zona') === zoneCode,
  );
  if (!coversZone) return null;

  const spanish =
    infos.find((info) => (tagValue(info, 'language') ?? '').startsWith('es')) ??
    infos[0];
  const valencian = infos.find((info) =>
    (tagValue(info, 'language') ?? '').startsWith('ca'),
  );

  // AEMET publica el nivel meteoalerta como parámetro con nombre; el
  // <severity> estándar de CAP es el respaldo si ese parámetro no viene.
  const level =
    namedValue(spanish, 'parameter', 'nivel') ??
    CAP_SEVERITY_FALLBACK[tagValue(spanish, 'severity') ?? ''] ??
    null;
  if (!level) return null;

  const phenomenon = tagValue(spanish, 'event');
  const spanishText = tagValue(spanish, 'description') ?? phenomenon;
  if (!phenomenon || !spanishText) return null;

  const startAt = parseDate(
    tagValue(spanish, 'onset') ?? tagValue(spanish, 'effective'),
  );
  if (!startAt) return null;

  let severity: AlertSeverity;
  try {
    severity = AlertSeverity.create(level);
  } catch {
    // Nivel desconocido (por ejemplo "verde"): no es un aviso publicable.
    return null;
  }

  return {
    externalId: identifier,
    severity,
    phenomenon,
    body: LocalizedText.create({
      es: spanishText,
      va: valencian
        ? (tagValue(valencian, 'description') ?? undefined)
        : undefined,
    }),
    startAt,
    endAt: parseDate(tagValue(spanish, 'expires')),
  };
}
