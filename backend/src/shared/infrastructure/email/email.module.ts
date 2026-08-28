import { Global, Module } from '@nestjs/common';
import { ConsoleEmailSenderAdapter } from './console-email-sender.adapter';
import { EMAIL_SENDER_PORT } from './email-sender.port';

@Global()
@Module({
  providers: [
    { provide: EMAIL_SENDER_PORT, useClass: ConsoleEmailSenderAdapter },
  ],
  exports: [EMAIL_SENDER_PORT],
})
export class EmailModule {}
