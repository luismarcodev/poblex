export interface CreateRefreshTokenParams {
  managerId: string;
  tokenHash: string;
  expiresAt: Date;
}

export interface StoredRefreshToken {
  id: string;
  managerId: string;
  expiresAt: Date;
  revokedAt: Date | null;
}

export interface RefreshTokenRepositoryPort {
  create(params: CreateRefreshTokenParams): Promise<void>;
  // Devuelve el registro tal cual — la validez (revocado/caducado) la
  // decide el caso de uso, no la consulta.
  findByHash(tokenHash: string): Promise<StoredRefreshToken | null>;
  // Atomic compare-and-set. Exactly one concurrent refresh may consume an
  // active token; later attempts receive false instead of minting siblings.
  revokeIfActive(id: string): Promise<boolean>;
  revokeAllForManager(managerId: string): Promise<void>;
}

export const REFRESH_TOKEN_REPOSITORY_PORT = Symbol(
  'REFRESH_TOKEN_REPOSITORY_PORT',
);
