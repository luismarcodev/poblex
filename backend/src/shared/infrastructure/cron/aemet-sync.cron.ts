import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { SyncAemetAlertsUseCase } from '../../../contexts/alerts/application/use-cases/sync-aemet-alerts.use-case';

@Injectable()
export class AemetSyncCron {
  private readonly logger = new Logger(AemetSyncCron.name);

  constructor(private readonly syncAemetAlerts: SyncAemetAlertsUseCase) {}

  // Cada 15 minutos, según el contrato del CLAUDE.md.
  @Cron('0 */15 * * * *')
  async run(): Promise<void> {
    const result = await this.syncAemetAlerts.execute();
    if (result.created > 0 || result.failedZones > 0) {
      this.logger.log(
        `AEMET sync: ${result.created} new alert(s), ${result.failedZones} failed zone(s)`,
      );
    }
  }
}
