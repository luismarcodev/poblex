import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { AutoArchiveNewsUseCase } from '../../../contexts/news/application/use-cases/auto-archive-news.use-case';

@Injectable()
export class NewsAutoArchiveCron {
  private readonly logger = new Logger(NewsAutoArchiveCron.name);

  constructor(private readonly autoArchiveNews: AutoArchiveNewsUseCase) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async run(): Promise<void> {
    const count = await this.autoArchiveNews.execute();
    this.logger.log(`Auto-archived ${count} news item(s)`);
  }
}
