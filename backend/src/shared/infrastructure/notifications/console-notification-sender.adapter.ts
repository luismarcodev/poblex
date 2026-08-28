import { Injectable, Logger } from '@nestjs/common';
import type {
  NotificationSenderPort,
  SendToTokensParams,
  SendToTokensResult,
  SendToTopicParams,
} from './notification-sender.port';

// Adaptador de desarrollo: imprime el push en logs en vez de enviarlo.
// Se usa cuando no hay credenciales de FCM configuradas.
@Injectable()
export class ConsoleNotificationSenderAdapter implements NotificationSenderPort {
  private readonly logger = new Logger(ConsoleNotificationSenderAdapter.name);

  sendToTopic(params: SendToTopicParams): Promise<void> {
    this.logger.log(
      `[DEV PUSH topic=${params.topic}] ${params.title} — ${params.body} ${JSON.stringify(params.data)}`,
    );
    return Promise.resolve();
  }

  sendToTokens(params: SendToTokensParams): Promise<SendToTokensResult> {
    this.logger.log(
      `[DEV PUSH tokens=${params.tokens.length}] ${params.title} — ${params.body} ${JSON.stringify(params.data)}`,
    );
    return Promise.resolve({ invalidTokens: [] });
  }
}
