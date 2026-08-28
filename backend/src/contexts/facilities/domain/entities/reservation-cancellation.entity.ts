import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';

export interface ReservationCancellationProps {
  id: string;
  facilityId: string;
  municipalityId: MunicipalityId;
  deviceId: string;
  slotStart: Date;
  slotEnd: Date;
  // Null si canceló el propio vecino; id del gestor si canceló el ayuntamiento.
  cancelledBy: string | null;
  cancelNote: string | null;
  cancelledAt: Date;
}

// Registro de solo-inserción: no se corrige, se añade. Ver el comentario del
// modelo Prisma para el porqué de borrar la reserva viva en vez de marcar un
// estado.
export class ReservationCancellation {
  private constructor(private readonly props: ReservationCancellationProps) {}

  static create(props: ReservationCancellationProps): ReservationCancellation {
    return new ReservationCancellation(props);
  }

  get id(): string {
    return this.props.id;
  }

  get facilityId(): string {
    return this.props.facilityId;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get deviceId(): string {
    return this.props.deviceId;
  }

  get slotStart(): Date {
    return this.props.slotStart;
  }

  get slotEnd(): Date {
    return this.props.slotEnd;
  }

  get cancelledBy(): string | null {
    return this.props.cancelledBy;
  }

  get cancelNote(): string | null {
    return this.props.cancelNote;
  }

  get cancelledAt(): Date {
    return this.props.cancelledAt;
  }

  get cancelledByManager(): boolean {
    return this.props.cancelledBy !== null;
  }
}
