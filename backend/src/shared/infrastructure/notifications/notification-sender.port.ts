export type NotificationLocale = 'es' | 'va';

// Payload común. `data` viaja siempre: la app la usa para el deep link
// (cada push abre la pantalla de detalle, nunca la de inicio).
export interface NotificationContent {
  title: string;
  body: string;
  data: Record<string, string>;
}

export interface SendToTopicParams extends NotificationContent {
  topic: string;
}

export interface SendToTokensParams extends NotificationContent {
  tokens: string[];
}

export interface SendToTokensResult {
  // Tokens rechazados por FCM (desinstalación, token rotado). El llamante
  // los limpia de `devices.fcm_token`: un token muerto es un push que nunca
  // llega y nadie se entera de por qué.
  invalidTokens: string[];
}

// Dos mecanismos distintos, no intercambiables:
//   - difusión por topic  → mismo contenido para todo el municipio
//   - dirigido por token  → un dispositivo concreto, en SU idioma
export interface NotificationSenderPort {
  sendToTopic(params: SendToTopicParams): Promise<void>;
  sendToTokens(params: SendToTokensParams): Promise<SendToTokensResult>;
}

export const NOTIFICATION_SENDER_PORT = Symbol('NOTIFICATION_SENDER_PORT');
