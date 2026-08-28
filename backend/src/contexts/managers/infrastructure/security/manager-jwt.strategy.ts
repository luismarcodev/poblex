import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AccessTokenPayload } from '../../domain/ports/token-generator.port';

@Injectable()
export class ManagerJwtStrategy extends PassportStrategy(
  Strategy,
  'manager-jwt',
) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_ACCESS_SECRET ?? '',
    });
  }

  validate(payload: AccessTokenPayload): AccessTokenPayload {
    return { managerId: payload.managerId };
  }
}
