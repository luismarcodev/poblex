import { IsOptional, IsString } from 'class-validator';

// Meta invoca este callback con `code`+`state` en éxito, o con parámetros de
// error (`error`, `error_reason`) si el gestor cancela el consentimiento —
// ninguno de los dos casos puede tumbar el endpoint con un 400 de validación,
// se resuelven ambos como redirect al backoffice.
export class OAuthCallbackQueryDto {
  @IsOptional()
  @IsString()
  code?: string;

  @IsOptional()
  @IsString()
  state?: string;

  @IsOptional()
  @IsString()
  error?: string;
}
