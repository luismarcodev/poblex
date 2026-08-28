import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type {
  WeatherWarning,
  WeatherWarningProviderPort,
} from '../../domain/ports/weather-warning.port';
import { parseCapDocument } from './cap-parser';
import { extractTarGz } from './tar-gz';

const AEMET_BASE_URL = 'https://opendata.aemet.es/opendata/api';

// Respuesta de la primera llamada: AEMET no devuelve los datos, devuelve la
// URL donde están (protocolo de dos pasos de OpenData).
interface AemetHandshake {
  estado: number;
  datos?: string;
  descripcion?: string;
}

// Adaptador de AEMET OpenData. Implementa el puerto de dominio: el dominio no
// sabe que AEMET existe, solo que alguien le da avisos por zona.
//
// La clave de API va en variables de entorno del backend, NUNCA en el repo ni
// en el cliente.
@Injectable()
export class AemetWeatherWarningAdapter implements WeatherWarningProviderPort {
  private readonly logger = new Logger(AemetWeatherWarningAdapter.name);
  private readonly apiKey: string;

  constructor(config: ConfigService) {
    this.apiKey = config.get<string>('AEMET_API_KEY', '');
  }

  async fetchWarningsForZone(zoneCode: string): Promise<WeatherWarning[]> {
    if (!this.apiKey) {
      throw new Error('AEMET_API_KEY is not configured');
    }

    // El endpoint de avisos trabaja por ÁREA (los dos primeros dígitos del
    // código de zona); el filtrado fino por zona lo hace el parser.
    const area = zoneCode.slice(0, 2);
    const handshake = await this.request(
      `${AEMET_BASE_URL}/avisos_cap/ultimoelaborado/area/${area}`,
    );

    if (handshake.estado !== 200 || !handshake.datos) {
      throw new Error(
        `AEMET handshake failed for area ${area}: estado=${handshake.estado} ${handshake.descripcion ?? ''}`,
      );
    }

    const payload = await fetch(handshake.datos);
    if (!payload.ok) {
      throw new Error(
        `AEMET data download failed for area ${area}: HTTP ${payload.status}`,
      );
    }

    const archive = Buffer.from(await payload.arrayBuffer());
    const documents = extractTarGz(archive).filter((entry) =>
      entry.name.toLowerCase().endsWith('.xml'),
    );

    const warnings: WeatherWarning[] = [];
    for (const document of documents) {
      try {
        const warning = parseCapDocument(document.content, zoneCode);
        if (warning) warnings.push(warning);
      } catch (error) {
        // Un documento ilegible no invalida el resto del lote: se registra y
        // se sigue. Perder un aviso por un fallo de parseo es malo; perder
        // todos los de la tanda es peor.
        this.logger.warn(
          `Unparseable CAP document ${document.name}: ${String(error)}`,
        );
      }
    }

    return warnings;
  }

  private async request(url: string): Promise<AemetHandshake> {
    const response = await fetch(url, {
      headers: { api_key: this.apiKey },
    });
    if (!response.ok) {
      throw new Error(`AEMET request failed: HTTP ${response.status}`);
    }
    return (await response.json()) as AemetHandshake;
  }
}
