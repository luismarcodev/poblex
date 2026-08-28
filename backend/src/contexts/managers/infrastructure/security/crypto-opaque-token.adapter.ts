import { createHash, randomBytes } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import {
  GeneratedOpaqueToken,
  OpaqueTokenPort,
} from '../../domain/ports/opaque-token.port';

const RAW_TOKEN_BYTES = 32;

@Injectable()
export class CryptoOpaqueTokenAdapter implements OpaqueTokenPort {
  generate(): GeneratedOpaqueToken {
    const rawToken = randomBytes(RAW_TOKEN_BYTES).toString('hex');
    return { rawToken, tokenHash: this.hash(rawToken) };
  }

  hash(rawToken: string): string {
    return createHash('sha256').update(rawToken).digest('hex');
  }
}
