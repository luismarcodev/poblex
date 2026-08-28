import {
  ForbiddenError,
  NotFoundError,
} from '../../../../shared/domain/errors/common-errors';

export class PharmacyNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Duty pharmacy not found: ${id}`);
  }
}

export class PharmacyForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}
