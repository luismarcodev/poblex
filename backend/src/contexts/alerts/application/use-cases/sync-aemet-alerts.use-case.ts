import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { EMAIL_SENDER_PORT } from '../../../../shared/infrastructure/email/email-sender.port';
import type { EmailSenderPort } from '../../../../shared/infrastructure/email/email-sender.port';
import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import { TaskHealthRegistry } from '../../../../shared/infrastructure/cron/task-health.registry';
import { MUNICIPALITY_READER_PORT } from '../../../municipalities/domain/ports/municipality-reader.port';
import type { MunicipalityReaderPort } from '../../../municipalities/domain/ports/municipality-reader.port';
import { ALERT_WRITER_PORT } from '../../domain/ports/alert-writer.port';
import type { AlertWriterPort } from '../../domain/ports/alert-writer.port';
import { WEATHER_WARNING_PROVIDER_PORT } from '../../domain/ports/weather-warning.port';
import type { WeatherWarningProviderPort } from '../../domain/ports/weather-warning.port';
import { AlertPhenomenonType } from '../../domain/value-objects/alert-phenomenon-type.vo';
import { AlertSource } from '../../domain/value-objects/alert-source.vo';

export const AEMET_SYNC_TASK = 'aemet-sync';

// Sollana está en la Ribera Baixa, zona con historial reciente de
// inundaciones: un fallo silencioso en la fuente de alertas meteorológicas no
// es tolerable. Tres fallos consecutivos disparan aviso por email.
const FAILURE_ALERT_THRESHOLD = 3;

export interface SyncResult {
  created: number;
  failedZones: number;
}

@Injectable()
export class SyncAemetAlertsUseCase {
  private readonly logger = new Logger(SyncAemetAlertsUseCase.name);

  constructor(
    @Inject(WEATHER_WARNING_PROVIDER_PORT)
    private readonly provider: WeatherWarningProviderPort,
    @Inject(ALERT_WRITER_PORT) private readonly writer: AlertWriterPort,
    @Inject(MUNICIPALITY_READER_PORT)
    private readonly municipalities: MunicipalityReaderPort,
    @Inject(EMAIL_SENDER_PORT) private readonly email: EmailSenderPort,
    private readonly broadcast: BroadcastNotifier,
    private readonly health: TaskHealthRegistry,
    private readonly config: ConfigService,
  ) {}

  async execute(): Promise<SyncResult> {
    const municipalities = await this.municipalities.findAllWithAemetZone();
    let created = 0;
    let failedZones = 0;

    for (const municipality of municipalities) {
      const zoneCode = municipality.aemetZoneCode;
      if (!zoneCode) continue;

      try {
        const warnings = await this.provider.fetchWarningsForZone(zoneCode);

        for (const warning of warnings) {
          // Deduplicación por aemet_id antes de insertar: la tarea corre cada
          // 15 minutos sobre el mismo aviso vigente.
          const alreadyStored = await this.writer.existsByAemetId(
            municipality.id,
            warning.externalId,
          );
          if (alreadyStored) continue;

          const alert = await this.writer.create({
            municipalityId: municipality.id,
            source: AlertSource.aemet(),
            severity: warning.severity,
            // AEMET solo trae fenómenos meteorológicos — nunca puede
            // autodeclararse incendio ni evacuación.
            phenomenonType: AlertPhenomenonType.meteorologico(),
            phenomenon: warning.phenomenon,
            body: warning.body,
            startAt: warning.startAt,
            endAt: warning.endAt,
            aemetId: warning.externalId,
            // Origen AEMET: sin gestor detrás, createdBy queda a null.
            createdBy: null,
          });
          created += 1;

          await this.broadcast.broadcast({
            municipalityId: municipality.id.value,
            channel: 'alerts',
            title: LocalizedText.create({
              es: `Aviso ${warning.severity.value}: ${warning.phenomenon}`,
              va: `Avís ${warning.severity.value}: ${warning.phenomenon}`,
            }),
            body: warning.body,
            data: {
              type: 'alert',
              id: alert.id,
              severity: warning.severity.value,
              forced: String(warning.severity.forcesNotification),
            },
          });
        }
      } catch (error) {
        failedZones += 1;
        this.logger.error(
          `AEMET sync failed for zone ${zoneCode}: ${String(error)}`,
        );
      }
    }

    if (failedZones > 0) {
      const consecutive = this.health.recordFailure(AEMET_SYNC_TASK);
      if (consecutive >= FAILURE_ALERT_THRESHOLD) {
        await this.notifyOperations(consecutive);
      }
    } else {
      this.health.recordSuccess(AEMET_SYNC_TASK);
    }

    return { created, failedZones };
  }

  private async notifyOperations(consecutiveFailures: number): Promise<void> {
    const to = this.config.get<string>('OPS_ALERT_EMAIL');
    if (!to) {
      this.logger.error(
        `AEMET sync has failed ${consecutiveFailures} times in a row and OPS_ALERT_EMAIL is not configured`,
      );
      return;
    }

    await this.email.send({
      to,
      subject: `[Poblex] Sincronización con AEMET fallando (${consecutiveFailures} intentos seguidos)`,
      text:
        `La tarea de sincronización con AEMET lleva ${consecutiveFailures} ejecuciones ` +
        `consecutivas con fallos. Los avisos meteorológicos pueden no estar llegando ` +
        `a los vecinos. Revisa la clave de API y el estado del servicio de AEMET.`,
    });
  }
}
