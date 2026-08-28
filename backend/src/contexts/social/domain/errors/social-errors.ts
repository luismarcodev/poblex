import {
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class SocialAccountNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Social account not found: ${id}`);
  }
}

export class SocialAccountForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

export class UnparsableInboundPostError extends ValidationError {
  constructor(externalId: string) {
    super(`Inbound post ${externalId} has no usable text or image`);
  }
}

export class OAuthStateInvalidError extends ValidationError {
  constructor() {
    super('OAuth state is invalid, expired, or was already used');
  }
}

export class SocialTokenExchangeError extends ValidationError {
  constructor(reason: string) {
    super(`Could not exchange the OAuth code for a token: ${reason}`);
  }
}
