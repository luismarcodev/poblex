import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { BusinessCategory } from '../value-objects/business-category.vo';
import { BusinessPhoto } from './business-photo.entity';

export interface BusinessProps {
  id: string;
  municipalityId: MunicipalityId;
  name: string;
  category: BusinessCategory;
  description: LocalizedText | null;
  address: string | null;
  phone: string | null;
  email: string | null;
  website: string | null;
  schedule: string | null;
  active: boolean;
  createdAt: Date;
  photos: BusinessPhoto[];
}

export class Business {
  private constructor(private readonly props: BusinessProps) {}

  static create(props: BusinessProps): Business {
    // Solo el nombre es obligatorio: dirección, teléfono, email, web y
    // horario son opcionales por decisión de producto (no todo comercio
    // tiene los siete campos rellenos de entrada).
    if (props.name.trim().length === 0) {
      throw new ValidationError('Business.name must not be empty');
    }
    return new Business(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get name(): string {
    return this.props.name;
  }

  get category(): BusinessCategory {
    return this.props.category;
  }

  get description(): LocalizedText | null {
    return this.props.description;
  }

  get address(): string | null {
    return this.props.address;
  }

  get phone(): string | null {
    return this.props.phone;
  }

  get email(): string | null {
    return this.props.email;
  }

  get website(): string | null {
    return this.props.website;
  }

  get schedule(): string | null {
    return this.props.schedule;
  }

  get active(): boolean {
    return this.props.active;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  get photos(): BusinessPhoto[] {
    return this.props.photos;
  }
}
