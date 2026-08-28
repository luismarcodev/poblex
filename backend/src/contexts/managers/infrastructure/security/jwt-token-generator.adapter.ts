import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { SignOptions } from 'jsonwebtoken';
import {
  AccessTokenPayload,
  TokenGeneratorPort,
} from '../../domain/ports/token-generator.port';

@Injectable()
export class JwtTokenGeneratorAdapter implements TokenGeneratorPort {
  constructor(private readonly jwt: JwtService) {}

  signAccessToken(payload: AccessTokenPayload): string {
    return this.jwt.sign(payload, {
      secret: process.env.JWT_ACCESS_SECRET,
      expiresIn: (process.env.JWT_ACCESS_EXPIRES_IN ??
        '15m') as SignOptions['expiresIn'],
    });
  }

  verifyAccessToken(token: string): AccessTokenPayload | null {
    try {
      return this.jwt.verify<AccessTokenPayload>(token, {
        secret: process.env.JWT_ACCESS_SECRET,
      });
    } catch {
      return null;
    }
  }
}
