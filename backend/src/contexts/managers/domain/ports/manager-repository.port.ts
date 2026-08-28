import { Manager } from '../entities/manager.entity';

export interface ManagerRepositoryPort {
  findByEmail(email: string): Promise<Manager | null>;
  findById(id: string): Promise<Manager | null>;
  updatePasswordHash(managerId: string, passwordHash: string): Promise<void>;
  // Comprobación de autorización real — se llama desde cada caso de uso que
  // escribe contenido de un municipio, no solo desde el guard HTTP.
  isManagerOfMunicipality(
    managerId: string,
    municipalityId: string,
  ): Promise<boolean>;

  // Municipios de la relación N:M del gestor. Devuelve solo identificadores:
  // los datos del municipio los sirve su propio contexto, este no los conoce.
  findMunicipalityIdsOf(managerId: string): Promise<string[]>;
}

export const MANAGER_REPOSITORY_PORT = Symbol('MANAGER_REPOSITORY_PORT');
