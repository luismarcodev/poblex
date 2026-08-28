import { Injectable, Logger } from '@nestjs/common';
import { EmailSenderPort, SendEmailParams } from './email-sender.port';

// Adapter de desarrollo: imprime el email en logs en vez de enviarlo.
// Sustituir por un proveedor real (Resend/SMTP) cuando haya credenciales.
@Injectable()
export class ConsoleEmailSenderAdapter implements EmailSenderPort {
  private readonly logger = new Logger(ConsoleEmailSenderAdapter.name);

  send(params: SendEmailParams): Promise<void> {
    this.logger.log(
      `[DEV EMAIL] To: ${params.to} | Subject: ${params.subject}\n${params.text}`,
    );
    return Promise.resolve();
  }
}
