import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { OpeningHours } from '../value-objects/opening-hours.vo';

export interface FacilityProps {
  id: string;
  municipalityId: MunicipalityId;
  name: LocalizedText;
  description: LocalizedText | null;
  category: string;
  imageUrl: string | null;
  slotDurationMinutes: number;
  openingHours: OpeningHours;
  feeNote: LocalizedText | null;
  maxAdvanceBookingDays: number;
  active: boolean;
  createdAt: Date;
}

export class Facility {
  private constructor(private readonly props: FacilityProps) {}

  static create(props: FacilityProps): Facility {
    if (props.slotDurationMinutes <= 0 || props.slotDurationMinutes > 480) {
      throw new ValidationError(
        `Invalid slotDurationMinutes: ${props.slotDurationMinutes} (expected 1-480)`,
      );
    }
    if (props.maxAdvanceBookingDays <= 0) {
      throw new ValidationError(
        `Invalid maxAdvanceBookingDays: ${props.maxAdvanceBookingDays} (must be positive)`,
      );
    }
    return new Facility(props);
  }

  get id(): string {
    return this.props.id;
  }

  get municipalityId(): MunicipalityId {
    return this.props.municipalityId;
  }

  get name(): LocalizedText {
    return this.props.name;
  }

  get description(): LocalizedText | null {
    return this.props.description;
  }

  get category(): string {
    return this.props.category;
  }

  get imageUrl(): string | null {
    return this.props.imageUrl;
  }

  get slotDurationMinutes(): number {
    return this.props.slotDurationMinutes;
  }

  get openingHours(): OpeningHours {
    return this.props.openingHours;
  }

  get feeNote(): LocalizedText | null {
    return this.props.feeNote;
  }

  get maxAdvanceBookingDays(): number {
    return this.props.maxAdvanceBookingDays;
  }

  get active(): boolean {
    return this.props.active;
  }

  get createdAt(): Date {
    return this.props.createdAt;
  }

  // Ventana de reserva permitida: ni en el pasado ni más allá del máximo de
  // antelación configurado.
  isWithinBookingWindow(slotStart: Date, now: Date): boolean {
    if (slotStart.getTime() <= now.getTime()) return false;
    const maxAdvanceMs = this.props.maxAdvanceBookingDays * 86_400_000;
    return slotStart.getTime() <= now.getTime() + maxAdvanceMs;
  }
}
