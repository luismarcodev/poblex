export interface AccessTokenPayload {
  managerId: string;
}

export interface TokenGeneratorPort {
  signAccessToken(payload: AccessTokenPayload): string;
  verifyAccessToken(token: string): AccessTokenPayload | null;
}

export const TOKEN_GENERATOR_PORT = Symbol('TOKEN_GENERATOR_PORT');
