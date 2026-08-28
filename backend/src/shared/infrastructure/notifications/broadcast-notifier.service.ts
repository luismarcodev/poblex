import { Inject, Injectable } from '@nestjs/common';
import { LocalizedText } from '../../domain/value-objects/localized-text';
import { NOTIFICATION_SENDER_PORT } from './notification-sender.port';
import type { NotificationSenderPort } from './notification-sender.port';
import { BROADCAST_LOCALES, BroadcastChannel, broadcastTopic } from './topics';

const PUSH_BODY_MAX_CHARS = 140;

export interface BroadcastParams {
  municipalityId: string;
  channel: BroadcastChannel;
  title: LocalizedText;
  body: LocalizedText;
  // Deep link: cada push abre la pantalla de detalle, no la de inicio.
  data: Record<string, string>;
}

function preview(text: string): string {
  return text.length <= PUSH_BODY_MAX_CHARS
    ? text
    : `${text.slice(0, PUSH_BODY_MAX_CHARS - 1).trimEnd()}…`;
}

// Difusión por topic: un envío POR IDIOMA, porque el idioma forma parte del
// nombre del topic. Los fallos de push no propagan — que no llegue un aviso
// no puede tumbar la publicación de la noticia que ya está guardada.
@Injectable()
export class BroadcastNotifier {
  constructor(
    @Inject(NOTIFICATION_SENDER_PORT)
    private readonly sender: NotificationSenderPort,
  ) {}

  async broadcast(params: BroadcastParams): Promise<void> {
    for (const locale of BROADCAST_LOCALES) {
      await this.sender.sendToTopic({
        topic: broadcastTopic(params.municipalityId, params.channel, locale),
        title: params.title.resolve(locale).text,
        body: preview(params.body.resolve(locale).text),
        data: params.data,
      });
    }
  }
}
