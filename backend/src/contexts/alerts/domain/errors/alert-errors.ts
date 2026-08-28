import {
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class AlertNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Alert not found: ${id}`);
  }
}

export class AlertForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

// Las alertas que vienen de AEMET son un espejo de la fuente oficial: si un
// gestor pudiera editarlas, el municipio publicaría un aviso meteorológico
// que AEMET nunca emitió, firmado como si lo hubiera emitido.
export class AemetAlertNotEditableError extends ValidationError {
  constructor(id: string) {
    super(`Alert ${id} comes from AEMET and cannot be edited manually`);
  }
}
