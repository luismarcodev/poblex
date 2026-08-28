import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpStatus,
} from '@nestjs/common';
import type { Response } from 'express';
import { DomainError } from '../../domain/errors/domain-error';
import {
  ConflictError,
  ForbiddenError,
  NotFoundError,
  UnauthorizedError,
  ValidationError,
} from '../../domain/errors/common-errors';

const STATUS_BY_ERROR: ReadonlyArray<
  [new (...args: never[]) => DomainError, number]
> = [
  [NotFoundError, HttpStatus.NOT_FOUND],
  [ValidationError, HttpStatus.BAD_REQUEST],
  [ForbiddenError, HttpStatus.FORBIDDEN],
  [ConflictError, HttpStatus.CONFLICT],
  [UnauthorizedError, HttpStatus.UNAUTHORIZED],
];

// Traduce errores de dominio tipados a respuesta HTTP. Es el único lugar del
// backend donde un DomainError se convierte en código de estado — los casos
// de uso y controladores nunca deciden códigos HTTP directamente.
@Catch(DomainError)
export class DomainExceptionFilter implements ExceptionFilter {
  catch(exception: DomainError, host: ArgumentsHost): void {
    const response = host.switchToHttp().getResponse<Response>();
    const status = this.resolveStatus(exception);

    response.status(status).json({
      statusCode: status,
      code: exception.code,
      message: exception.message,
    });
  }

  private resolveStatus(exception: DomainError): number {
    for (const [errorClass, status] of STATUS_BY_ERROR) {
      if (exception instanceof errorClass) return status;
    }
    return HttpStatus.INTERNAL_SERVER_ERROR;
  }
}
