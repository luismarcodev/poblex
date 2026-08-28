import { DomainError } from './domain-error';

export class NotFoundError extends DomainError {
  readonly code = 'NOT_FOUND';
  constructor(message: string) {
    super(message);
  }
}

export class ValidationError extends DomainError {
  readonly code = 'VALIDATION_ERROR';
  constructor(message: string) {
    super(message);
  }
}

export class ForbiddenError extends DomainError {
  readonly code = 'FORBIDDEN';
  constructor(message: string) {
    super(message);
  }
}

export class ConflictError extends DomainError {
  readonly code = 'CONFLICT';
  constructor(message: string) {
    super(message);
  }
}

export class UnauthorizedError extends DomainError {
  readonly code = 'UNAUTHORIZED';
  constructor(message: string) {
    super(message);
  }
}
