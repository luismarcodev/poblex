import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PurgeIncidentPhotosUseCase } from '../../../contexts/incidents/application/use-cases/purge-incident-photos.use-case';

@Injectable()
export class IncidentPhotoPurgeCron {
  private readonly logger = new Logger(IncidentPhotoPurgeCron.name);

  constructor(
    private readonly purgeIncidentPhotos: PurgeIncidentPhotosUseCase,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_4AM)
  async run(): Promise<void> {
    const count = await this.purgeIncidentPhotos.execute();
    if (count > 0) {
      this.logger.log(`Purged ${count} incident photo(s)`);
    }
  }
}
