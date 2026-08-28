import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Municipality } from '../entities/municipality.entity';

export interface MunicipalityReaderPort {
  findAllActive(): Promise<Municipality[]>;
  findActiveById(id: MunicipalityId): Promise<Municipality | null>;
  // Municipios activos con zona AEMET configurada: los únicos que la tarea
  // de sincronización meteorológica tiene que consultar.
  findAllWithAemetZone(): Promise<Municipality[]>;
}

export const MUNICIPALITY_READER_PORT = Symbol('MUNICIPALITY_READER_PORT');
