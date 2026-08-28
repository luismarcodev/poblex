import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type StatusValue = 'recibido' | 'en_curso' | 'resuelta';

const STATUSES: readonly StatusValue[] = ['recibido', 'en_curso', 'resuelta'];

export class IncidentStatus {
  private constructor(readonly value: StatusValue) {}

  static create(value: string): IncidentStatus {
    const normalized = value.trim().toLowerCase();
    if (!STATUSES.includes(normalized as StatusValue)) {
      throw new ValidationError(
        `Invalid IncidentStatus: "${value}" (expected recibido, en_curso or resuelta)`,
      );
    }
    return new IncidentStatus(normalized as StatusValue);
  }

  static received(): IncidentStatus {
    return new IncidentStatus('recibido');
  }

  get isResolved(): boolean {
    return this.value === 'resuelta';
  }

  canTransitionTo(next: IncidentStatus): boolean {
    if (this.equals(next) || this.isResolved) {
      return false;
    }
    return this.value === 'recibido' || next.isResolved;
  }

  equals(other: IncidentStatus): boolean {
    return this.value === other.value;
  }
}
