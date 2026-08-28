import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PurgeInactiveDevicesUseCase } from '../../../contexts/devices/application/use-cases/purge-inactive-devices.use-case';

@Injectable()
export class InactiveDevicesCleanupCron {
  private readonly logger = new Logger(InactiveDevicesCleanupCron.name);

  constructor(
    private readonly purgeInactiveDevices: PurgeInactiveDevicesUseCase,
  ) {}

  @Cron(CronExpression.EVERY_WEEK)
  async run(): Promise<void> {
    const count = await this.purgeInactiveDevices.execute();
    this.logger.log(`Purged ${count} inactive device(s)`);
  }
}
