import type { NotificationLocale } from './notification-sender.port';

export type BroadcastChannel = 'news' | 'events' | 'alerts';

// El idioma va en el NOMBRE del topic, no en la carga: un topic entrega el
// mismo payload a todos sus suscriptores, así que sin esto es imposible
// mandar el aviso en castellano a unos vecinos y en valenciano a otros.
//
// FCM exige que el nombre case con [a-zA-Z0-9-_.~%]+, así que los guiones
// del UUID se quedan y no hace falta escapar nada.
export function broadcastTopic(
  municipalityId: string,
  channel: BroadcastChannel,
  locale: NotificationLocale,
): string {
  return `m_${municipalityId}_${channel}_${locale}`;
}

// Difusión completa: un envío por idioma soportado.
export const BROADCAST_LOCALES: readonly NotificationLocale[] = ['es', 'va'];
