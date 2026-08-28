import {
  ConflictError,
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class FormNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Form not found: ${id}`);
  }
}

export class FormForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

export class FormClosedError extends ValidationError {
  constructor(id: string) {
    super(`Form ${id} is past its deadline and no longer accepts submissions`);
  }
}

export class InvalidSubmissionError extends ValidationError {
  constructor(reasons: string[]) {
    super(`Invalid submission: ${reasons.join('; ')}`);
  }
}

export class AlreadySubmittedError extends ConflictError {
  constructor(formId: string) {
    super(`This device has already submitted form ${formId}`);
  }
}
