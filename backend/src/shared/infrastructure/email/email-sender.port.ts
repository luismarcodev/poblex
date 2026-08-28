export interface SendEmailParams {
  to: string;
  subject: string;
  text: string;
}

export interface EmailSenderPort {
  send(params: SendEmailParams): Promise<void>;
}

export const EMAIL_SENDER_PORT = Symbol('EMAIL_SENDER_PORT');
