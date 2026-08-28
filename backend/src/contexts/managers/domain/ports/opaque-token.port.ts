export interface GeneratedOpaqueToken {
  rawToken: string;
  tokenHash: string;
}

// Para refresh tokens y tokens de recuperación de contraseña: nunca se
// guarda el valor en claro, solo su hash. El valor crudo viaja al cliente
// una única vez (cookie o email) y no se puede recuperar del hash.
export interface OpaqueTokenPort {
  generate(): GeneratedOpaqueToken;
  hash(rawToken: string): string;
}

export const OPAQUE_TOKEN_PORT = Symbol('OPAQUE_TOKEN_PORT');
