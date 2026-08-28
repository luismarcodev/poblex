import { DomainError } from './errors/domain-error';

interface MatchHandlers<T, R> {
  onSuccess: (value: T) => R;
  onFailure: (error: DomainError) => R;
}

export class Success<T> {
  readonly isSuccess = true as const;
  readonly isFailure = false as const;

  constructor(readonly value: T) {}

  match<R>(handlers: MatchHandlers<T, R>): R {
    return handlers.onSuccess(this.value);
  }
}

export class Failure<T> {
  readonly isSuccess = false as const;
  readonly isFailure = true as const;

  constructor(readonly error: DomainError) {}

  match<R>(handlers: MatchHandlers<T, R>): R {
    return handlers.onFailure(this.error);
  }
}

// Unión discriminada (no jerarquía de clases): permite que TypeScript
// estreche `result.isFailure` a `Failure<T>` y exponga `.error`, y
// `result.isSuccess` a `Success<T>` con `.value`, sin casts.
export type Result<T> = Success<T> | Failure<T>;

export const Result = {
  success<T>(value: T): Result<T> {
    return new Success(value);
  },
  failure<T = never>(error: DomainError): Result<T> {
    return new Failure(error);
  },
};
