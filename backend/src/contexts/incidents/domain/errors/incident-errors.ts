import {
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class IncidentNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Incident not found: ${id}`);
  }
}

export class IncidentForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

// Las incidencias son PRIVADAS: solo las ve el gestor y el vecino que la
// reportó. No existe listado público.
export class IncidentNotOwnedError extends ForbiddenError {
  constructor(incidentId: string) {
    super(`Incident ${incidentId} was not reported by this device`);
  }
}

export class InvalidIncidentStatusTransitionError extends ValidationError {
  constructor(current: string, next: string) {
    super(`Invalid incident status transition: ${current} -> ${next}`);
  }
}
