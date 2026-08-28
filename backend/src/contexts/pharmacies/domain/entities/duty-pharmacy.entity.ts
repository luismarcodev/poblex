import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';

export interface DutyPharmacyProps {
  id: string;
  municipalityId: MunicipalityId;
  // Día de guardia. Solo la fecha importa, no la hora.
  date: Date;
  pharmacyName: string;
  address: string;
  phone: string;
  schedule: string;
}

// Carga MANUAL por el gestor: no hay API oficial abierta en la Comunidad
// Valenciana y no se hace scraping de terceros para un dato sanitario.
export class DutyPharmacy {
  private constructor(private readonly props: DutyPharmacyProps) {}

  static create(props: DutyPharmacyProps): DutyPharmacy {
    for (const [field, value] of Object.entries({
      pharmacyName: props.pharmacyName,
      address: props.address,
      phone: props.phone,
      schedule: props.schedule,
    })) {
      if (value.trim().length === 0) {
        // Un dato sanitario incompleto es peor que no tenerlo: un vecino con
        // una urgencia a las tres de la mañana necesita nombre, dirección y
        // teléfono completos.
        throw new ValidationError(`DutyPharmacy.${field} must not be empty`);
      }
    }
    return new DutyPharmacy(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get date(): Date {
    return this.props.date;
  }

  get pharmacyName(): string {
    return this.props.pharmacyName;
  }

  get address(): string {
    return this.props.address;
  }

  get phone(): string {
    return this.props.phone;
  }

  get schedule(): string {
    return this.props.schedule;
  }
}
