import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { SendDueEventRemindersUseCase } from '../../../contexts/events/application/use-cases/send-due-event-reminders.use-case';

@Injectable()
export class EventRemindersCron {
  private readonly logger = new Logger(EventRemindersCron.name);

  constructor(
    private readonly sendDueEventReminders: SendDueEventRemindersUseCase,
  ) {}

  @Cron(CronExpression.EVERY_10_MINUTES)
  async run(): Promise<void> {
    const count = await this.sendDueEventReminders.execute();
    if (count > 0) {
      this.logger.log(`Sent ${count} event reminder(s)`);
    }
  }
}
