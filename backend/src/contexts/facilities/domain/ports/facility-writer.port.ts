import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Facility } from '../entities/facility.entity';
import { OpeningHours } from '../value-objects/opening-hours.vo';

export interface CreateFacilityParams {
  municipalityId: MunicipalityId;
  name: LocalizedText;
  description: LocalizedText | null;
  category: string;
  imageUrl: string | null;
  slotDurationMinutes: number;
  openingHours: OpeningHours;
  feeNote: LocalizedText | null;
  maxAdvanceBookingDays: number;
}

export interface UpdateFacilityFields {
  name?: LocalizedText;
  description?: LocalizedText | null;
  category?: string;
  imageUrl?: string | null;
  slotDurationMinutes?: number;
  openingHours?: OpeningHours;
  feeNote?: LocalizedText | null;
  maxAdvanceBookingDays?: number;
  active?: boolean;
}

export interface FacilityWriterPort {
  create(params: CreateFacilityParams): Promise<Facility>;
  update(id: string, fields: UpdateFacilityFields): Promise<Facility>;
}

export const FACILITY_WRITER_PORT = Symbol('FACILITY_WRITER_PORT');
