import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { BroadcastNotifier } from './broadcast-notifier.service';
import { ConsoleNotificationSenderAdapter } from './console-notification-sender.adapter';
import { FcmNotificationSenderAdapter } from './fcm-notification-sender.adapter';
import { NOTIFICATION_SENDER_PORT } from './notification-sender.port';

@Global()
@Module({
  providers: [
    {
      provide: NOTIFICATION_SENDER_PORT,
      // Sin credenciales de FCM se cae al adaptador de consola: en desarrollo
      // el flujo completo sigue siendo ejecutable sin proyecto de Firebase.
      useFactory: (config: ConfigService) =>
        config.get<string>('FCM_CREDENTIALS_JSON')
          ? new FcmNotificationSenderAdapter(config)
          : new ConsoleNotificationSenderAdapter(),
      inject: [ConfigService],
    },
    BroadcastNotifier,
  ],
  exports: [NOTIFICATION_SENDER_PORT, BroadcastNotifier],
})
export class NotificationsModule {}
