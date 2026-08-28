import {
  ForbiddenError,
  NotFoundError,
  ValidationError,
} from '../../../../shared/domain/errors/common-errors';

export class EventNotFoundError extends NotFoundError {
  constructor(id: string) {
    super(`Event not found: ${id}`);
  }
}

export class EventForbiddenError extends ForbiddenError {
  constructor(managerId: string, municipalityId: string) {
    super(
      `Manager ${managerId} is not authorized for municipality ${municipalityId}`,
    );
  }
}

export class ReminderAfterEventStartError extends ValidationError {
  constructor(eventId: string) {
    super(`Reminder time is not before the start of event ${eventId}`);
  }
}
