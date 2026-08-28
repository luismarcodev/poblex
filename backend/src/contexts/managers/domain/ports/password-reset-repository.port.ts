export interface CreatePasswordResetParams {
  managerId: string;
  tokenHash: string;
  expiresAt: Date;
}

export interface StoredPasswordReset {
  id: string;
  managerId: string;
  expiresAt: Date;
  usedAt: Date | null;
}

export interface PasswordResetRepositoryPort {
  create(params: CreatePasswordResetParams): Promise<void>;
  findByHash(tokenHash: string): Promise<StoredPasswordReset | null>;
  markUsed(id: string): Promise<void>;
}

export const PASSWORD_RESET_REPOSITORY_PORT = Symbol(
  'PASSWORD_RESET_REPOSITORY_PORT',
);
