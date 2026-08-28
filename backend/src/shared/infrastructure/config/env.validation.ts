import { Type, plainToInstance } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
  validateSync,
} from 'class-validator';

class EnvironmentVariables {
  @IsIn(['development', 'production', 'test'])
  NODE_ENV = 'development';

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(65535)
  PORT = 3000;

  @IsString()
  DATABASE_URL!: string;

  @IsString()
  JWT_ACCESS_SECRET!: string;

  @IsString()
  JWT_ACCESS_EXPIRES_IN = '15m';

  @IsString()
  JWT_REFRESH_EXPIRES_IN = '30d';

  @Type(() => Number)
  @IsInt()
  PASSWORD_RESET_TOKEN_TTL_MIN = 60;

  @Type(() => Number)
  @IsInt()
  THROTTLE_LOGIN_LIMIT = 5;

  @Type(() => Number)
  @IsInt()
  THROTTLE_LOGIN_TTL_SECONDS = 900;

  @IsString()
  CORS_ORIGIN!: string;

  @IsOptional()
  @IsString()
  BACKOFFICE_PUBLIC_URL?: string;

  @IsOptional()
  @IsString()
  R2_ENDPOINT?: string;

  @IsOptional()
  @IsString()
  R2_BUCKET?: string;

  @IsOptional()
  @IsString()
  R2_ACCESS_KEY?: string;

  @IsOptional()
  @IsString()
  R2_SECRET_KEY?: string;

  @IsOptional()
  @IsString()
  R2_PUBLIC_BASE_URL?: string;

  // Clave de AEMET OpenData. Sin ella el adaptador falla explícitamente en vez
  // de fingir que no hay avisos meteorológicos.
  @IsOptional()
  @IsString()
  AEMET_API_KEY?: string;

  // Destino del aviso automático tras 3 fallos seguidos de la sincronización
  // con AEMET. Sin configurar, el fallo solo queda en logs.
  @IsOptional()
  @IsString()
  OPS_ALERT_EMAIL?: string;

  @IsOptional()
  @IsString()
  FCM_PROJECT_ID?: string;

  @IsOptional()
  @IsString()
  FCM_CREDENTIALS_JSON?: string;

  // App OAuth global de Poblex en Meta ("Facebook Login for Business").
  // Sin ella el módulo de redes sociales cae a los adaptadores fake de
  // desarrollo — nunca inventa credenciales ni llama a Meta sin configurar.
  @IsOptional()
  @IsString()
  META_APP_ID?: string;

  @IsOptional()
  @IsString()
  META_APP_SECRET?: string;

  // Debe apuntar a .../v1/social/oauth/callback, registrado en la app de
  // Meta como redirect URI válido.
  @IsOptional()
  @IsString()
  META_OAUTH_REDIRECT_URI?: string;

  // Clave AES-256 en base64 (32 bytes decodificados) para cifrar en reposo
  // los access tokens de SocialAccount. Ver TokenCipherService.
  @IsOptional()
  @IsString()
  SOCIAL_TOKEN_ENCRYPTION_KEY?: string;
}

export function validateEnv(
  config: Record<string, unknown>,
): EnvironmentVariables {
  const validated = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });
  const errors = validateSync(validated, { skipMissingProperties: false });

  if (errors.length > 0) {
    throw new Error(`Invalid environment variables:\n${errors.toString()}`);
  }

  return validated;
}
