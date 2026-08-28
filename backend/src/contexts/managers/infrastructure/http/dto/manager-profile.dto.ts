import { ApiProperty } from '@nestjs/swagger';

// Forma propia y no el DTO del contexto de municipios: dos contextos no
// comparten su capa HTTP. Si municipios cambia su respuesta pública, el perfil
// del gestor no tiene por qué cambiar con ella.
export class ManagedMunicipalityDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  slug!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  province!: string;

  @ApiProperty({ nullable: true, type: String })
  primaryColor!: string | null;

  @ApiProperty({ nullable: true, type: String })
  logoUrl!: string | null;

  @ApiProperty({ type: [String] })
  languages!: string[];
}

// El hash de contraseña NUNCA sale del backend: la entidad no se serializa
// directamente, pasa por este DTO.
export class ManagerProfileResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  email!: string;

  @ApiProperty()
  displayName!: string;

  @ApiProperty({
    type: [ManagedMunicipalityDto],
    description:
      'Municipios que gestiona. Relación N:M: puede llevar más de uno.',
  })
  municipalities!: ManagedMunicipalityDto[];
}
