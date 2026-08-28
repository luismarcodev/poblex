import {
  ForbiddenError,
  NotFoundError,
} from '../../../../shared/domain/errors/common-errors';

export class NewsNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`News not found: ${id}`);
  }
}

export class NewsForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}
