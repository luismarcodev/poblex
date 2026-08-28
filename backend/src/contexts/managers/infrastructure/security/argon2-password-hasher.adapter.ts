import * as argon2 from 'argon2';
import { Injectable } from '@nestjs/common';
import { PasswordHasherPort } from '../../domain/ports/password-hasher.port';

@Injectable()
export class Argon2PasswordHasherAdapter implements PasswordHasherPort {
  hash(plain: string): Promise<string> {
    return argon2.hash(plain);
  }

  verify(hash: string, plain: string): Promise<boolean> {
    return argon2.verify(hash, plain);
  }
}
