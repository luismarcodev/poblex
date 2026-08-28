import {
  ForbiddenError,
  NotFoundError,
} from '../../../../shared/domain/errors/common-errors';

export class BusinessNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Business not found: ${id}`);
  }
}

export class BusinessForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}
