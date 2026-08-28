import type { ConfigService } from '@nestjs/config';
import { TokenCipherService } from './token-cipher.service';

const VALID_KEY = Buffer.alloc(32, 7).toString('base64');

function buildService(key: string | null = VALID_KEY): TokenCipherService {
  const config = {
    get: jest.fn().mockReturnValue(key ?? undefined),
  } as unknown as ConfigService;
  return new TokenCipherService(config);
}

describe('TokenCipherService', () => {
  it('round-trips a plaintext token', () => {
    const service = buildService();
    const blob = service.encrypt('EAABsbCS...long-lived-token');

    expect(service.decrypt(blob)).toBe('EAABsbCS...long-lived-token');
  });

  it('produces a different ciphertext each time (random IV)', () => {
    const service = buildService();
    const first = service.encrypt('same-token');
    const second = service.encrypt('same-token');

    expect(first.equals(second)).toBe(false);
    expect(service.decrypt(first)).toBe('same-token');
    expect(service.decrypt(second)).toBe('same-token');
  });

  it('throws on a corrupted blob instead of silently returning garbage', () => {
    const service = buildService();
    const blob = service.encrypt('a-real-token');
    blob[blob.length - 1] ^= 0xff; // flip the last ciphertext byte

    expect(() => service.decrypt(blob)).toThrow();
  });

  it('throws on a blob too short to contain iv+authTag', () => {
    const service = buildService();

    expect(() => service.decrypt(Buffer.alloc(4))).toThrow(
      'too short to be valid',
    );
  });

  it('throws when the encryption key is not configured', () => {
    const service = buildService(null);

    expect(() => service.encrypt('x')).toThrow(
      'SOCIAL_TOKEN_ENCRYPTION_KEY is not configured',
    );
  });

  it('throws when the encryption key does not decode to 32 bytes', () => {
    const service = buildService(Buffer.alloc(16).toString('base64'));

    expect(() => service.encrypt('x')).toThrow('exactly 32 bytes');
  });

  it('cannot decrypt with a different key than the one used to encrypt', () => {
    const encryptor = buildService(Buffer.alloc(32, 1).toString('base64'));
    const blob = encryptor.encrypt('secret');
    const decryptor = buildService(Buffer.alloc(32, 2).toString('base64'));

    expect(() => decryptor.decrypt(blob)).toThrow();
  });
});
