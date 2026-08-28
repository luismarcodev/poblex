import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

// Entrada bilingüe {es, va}. Ambos opcionales aquí: que haya al menos un
// idioma lo garantiza el value object LocalizedText del dominio, no el DTO.
export class LocalizedTextDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  es?: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  va?: string;
}
