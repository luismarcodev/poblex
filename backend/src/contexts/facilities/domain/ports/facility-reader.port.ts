import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Facility } from '../entities/facility.entity';

export interface FindFacilitiesParams {
  municipalityId: MunicipalityId;
  category?: string;
  // El listado público solo devuelve activas; el del gestor las quiere todas.
  onlyActive: boolean;
}

export interface FacilityReaderPort {
  find(params: FindFacilitiesParams): Promise<Facility[]>;
  findById(id: string): Promise<Facility | null>;
  findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Facility | null>;
}

export const FACILITY_READER_PORT = Symbol('FACILITY_READER_PORT');
