import { Inject, Injectable } from '@nestjs/common';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { NOTIFICATION_SENDER_PORT } from '../../../../shared/infrastructure/notifications/notification-sender.port';
import type {
  NotificationLocale,
  NotificationSenderPort,
} from '../../../../shared/infrastructure/notifications/notification-sender.port';
import { DEVICE_READER_PORT } from '../../domain/ports/device-reader.port';
import type { DeviceReaderPort } from '../../domain/ports/device-reader.port';

// Contenido a enviar, resuelto por idioma del dispositivo destinatario.
export interface LocalizedNotification {
  title: Record<NotificationLocale, string>;
  body: Record<NotificationLocale, string>;
  data: Record<string, string>;
}

function resolveLocale(locale: string): NotificationLocale {
  return locale.toLowerCase().startsWith('ca') || locale.toLowerCase() === 'va'
    ? 'va'
    : 'es';
}

// Envío DIRIGIDO por token: cambio de estado de incidencia, recordatorio de
// evento. Nunca por topic — un topic entregaría el aviso a todo el municipio.
//
// Vive en `devices` porque necesita el puerto de lectura de dispositivos; los
// demás contextos lo consumen importando DevicesModule.
@Injectable()
export class NotifyDevicesService {
  constructor(
    @Inject(DEVICE_READER_PORT) private readonly devices: DeviceReaderPort,
    @Inject(NOTIFICATION_SENDER_PORT)
    private readonly sender: NotificationSenderPort,
  ) {}

  async notify(
    deviceIds: DeviceId[],
    notification: LocalizedNotification,
  ): Promise<void> {
    const targets = await this.devices.findPushTargets(deviceIds);
    if (targets.length === 0) return;

    // Un envío por idioma: el texto se resuelve con `devices.locale`.
    const byLocale = new Map<NotificationLocale, string[]>();
    for (const target of targets) {
      const locale = resolveLocale(target.locale);
      const tokens = byLocale.get(locale) ?? [];
      tokens.push(target.fcmToken);
      byLocale.set(locale, tokens);
    }

    const deadTokens: string[] = [];
    for (const [locale, tokens] of byLocale) {
      const result = await this.sender.sendToTokens({
        tokens,
        title: notification.title[locale],
        body: notification.body[locale],
        data: notification.data,
      });
      deadTokens.push(...result.invalidTokens);
    }

    await this.devices.invalidateTokens(deadTokens);
  }
}
