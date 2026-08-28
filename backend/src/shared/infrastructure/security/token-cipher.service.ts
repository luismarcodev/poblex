import { createCipheriv, createDecipheriv, randomBytes } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

const ALGORITHM = 'aes-256-gcm';
const KEY_BYTES = 32;
const IV_BYTES = 12; // 96-bit IV, el tamaño estándar y más eficiente para GCM.
const AUTH_TAG_BYTES = 16;

// Cifra en reposo los access tokens de redes sociales (SocialAccount).
// AES-256-GCM con node:crypto nativo — mismo espíritu que
// CryptoOpaqueTokenAdapter (sin dependencia nueva). A diferencia de un hash
// de un sentido (como ManagerRefreshToken.tokenHash), aquí hace falta poder
// RECUPERAR el token en claro para llamar a la API de Meta, así que un hash
// no vale: tiene que ser cifrado reversible.
@Injectable()
export class TokenCipherService {
  constructor(private readonly config: ConfigService) {}

  // Formato del blob: iv (12) + authTag (16) + ciphertext.
  encrypt(plaintext: string): Buffer {
    const key = this.key();
    const iv = randomBytes(IV_BYTES);
    const cipher = createCipheriv(ALGORITHM, key, iv);
    const ciphertext = Buffer.concat([
      cipher.update(plaintext, 'utf8'),
      cipher.final(),
    ]);
    const authTag = cipher.getAuthTag();
    return Buffer.concat([iv, authTag, ciphertext]);
  }

  // Lanza si el blob está corrupto o la clave no coincide — GCM nunca
  // "descifra basura" en silencio, el fallo de autenticación es explícito.
  decrypt(blob: Buffer): string {
    if (blob.length < IV_BYTES + AUTH_TAG_BYTES) {
      throw new Error('Token cipher blob is too short to be valid');
    }
    const key = this.key();
    const iv = blob.subarray(0, IV_BYTES);
    const authTag = blob.subarray(IV_BYTES, IV_BYTES + AUTH_TAG_BYTES);
    const ciphertext = blob.subarray(IV_BYTES + AUTH_TAG_BYTES);

    const decipher = createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);
    const plaintext = Buffer.concat([
      decipher.update(ciphertext),
      decipher.final(),
    ]);
    return plaintext.toString('utf8');
  }

  private key(): Buffer {
    const raw = this.config.get<string>('SOCIAL_TOKEN_ENCRYPTION_KEY');
    if (!raw) {
      throw new Error('SOCIAL_TOKEN_ENCRYPTION_KEY is not configured');
    }
    const key = Buffer.from(raw, 'base64');
    if (key.length !== KEY_BYTES) {
      throw new Error(
        `SOCIAL_TOKEN_ENCRYPTION_KEY must decode to exactly ${KEY_BYTES} bytes`,
      );
    }
    return key;
  }
}
