import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { AlertPhenomenonType } from '../value-objects/alert-phenomenon-type.vo';
import { AlertSeverity } from '../value-objects/alert-severity.vo';
import { AlertSource } from '../value-objects/alert-source.vo';

export interface AlertProps {
  id: string;
  municipalityId: MunicipalityId;
  source: AlertSource;
  severity: AlertSeverity;
  phenomenonType: AlertPhenomenonType;
  phenomenon: string;
  body: LocalizedText;
  startAt: Date;
  endAt: Date | null;
  aemetId: string | null;
  // Auditoría: quién publicó y quién modificó. Null si el origen es AEMET.
  // Un sistema que notifica una emergencia a todo un municipio necesita saber
  // siempre quién publicó qué.
  createdBy: string | null;
  updatedBy: string | null;
  createdAt: Date;
}

export class Alert {
  private constructor(private readonly props: AlertProps) {}

  static create(props: AlertProps): Alert {
    if (props.endAt && props.endAt.getTime() < props.startAt.getTime()) {
      throw new ValidationError('Alert endAt must not precede startAt');
    }
    // Trazabilidad no negociable: una alerta manual sin autor no es auditable.
    if (props.source.isManual && !props.createdBy) {
      throw new ValidationError('Manual alerts require createdBy (manager id)');
    }
    // Y al revés: una alerta de AEMET tiene que traer su identificador de
    // origen, que es lo que permite deduplicar entre sincronizaciones.
    if (props.source.isAemet && !props.aemetId) {
      throw new ValidationError('AEMET alerts require aemetId');
    }
    return new Alert(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get source(): AlertSource {
    return this.props.source;
  }

  get severity(): AlertSeverity {
    return this.props.severity;
  }

  get phenomenonType(): AlertPhenomenonType {
    return this.props.phenomenonType;
  }

  get phenomenon(): string {
    return this.props.phenomenon;
  }

  get body(): LocalizedText {
    return this.props.body;
  }

  get startAt(): Date {
    return this.props.startAt;
  }

  get endAt(): Date | null {
    return this.props.endAt;
  }

  get aemetId(): string | null {
    return this.props.aemetId;
  }

  get createdBy(): string | null {
    return this.props.createdBy;
  }

  get updatedBy(): string | null {
    return this.props.updatedBy;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  // Vigente si ya empezó y no ha terminado. Una alerta sin fin se considera
  // vigente hasta que un gestor o AEMET la cierren.
  isActiveAt(instant: Date): boolean {
    const started = this.props.startAt.getTime() <= instant.getTime();
    const ended = this.props.endAt
      ? this.props.endAt.getTime() < instant.getTime()
      : false;
    return started && !ended;
  }
}
