import { IncidentStatus } from '../value-objects/incident-status.vo';

export interface IncidentStatusChangeProps {
  id: string;
  incidentId: string;
  status: IncidentStatus;
  note: string | null;
  changedAt: Date;
  changedBy: string;
}

// Entrada del historial de estados. Inmutable por definición: el historial no
// se corrige, se amplía.
export class IncidentStatusChange {
  private constructor(private readonly props: IncidentStatusChangeProps) {}

  static create(props: IncidentStatusChangeProps): IncidentStatusChange {
    return new IncidentStatusChange(props);
  }

  get id(): string {
    return this.props.id;
  }

  get incidentId(): string {
    return this.props.incidentId;
  }

  get status(): IncidentStatus {
    return this.props.status;
  }

  get note(): string | null {
    return this.props.note;
  }

  get changedAt(): Date {
    return this.props.changedAt;
  }

  get changedBy(): string {
    return this.props.changedBy;
  }
}
