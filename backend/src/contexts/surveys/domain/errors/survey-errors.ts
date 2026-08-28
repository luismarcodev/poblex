import {
  ConflictError,
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class SurveyNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Survey not found: ${id}`);
  }
}

export class SurveyForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

export class SurveyClosedError extends ValidationError {
  constructor(id: string) {
    super(`Survey ${id} is closed and no longer accepts votes`);
  }
}

export class UnknownSurveyOptionError extends ValidationError {
  constructor(surveyId: string, optionId: string) {
    super(`Option ${optionId} does not belong to survey ${surveyId}`);
  }
}

// La garantía real es la restricción UNIQUE (survey_id, device_id) de la base
// de datos. La aplicación comprueba antes solo para dar un mensaje decente.
export class AlreadyVotedError extends ConflictError {
  constructor(surveyId: string) {
    super(`This device has already voted in survey ${surveyId}`);
  }
}
