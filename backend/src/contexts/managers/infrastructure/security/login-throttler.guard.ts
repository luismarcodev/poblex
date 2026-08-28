import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import type { ThrottlerRequest } from '@nestjs/throttler/dist/throttler.guard.interface';

interface LoginRequestBody {
  email?: unknown;
}

// El límite de intentos de login se aplica por IP + email combinados, no
// solo por IP — dos vecinos detrás del mismo NAT no deben bloquearse entre
// sí, y un atacante no puede esquivar el límite rotando solo la IP si el
// email objetivo se mantiene fijo.
@Injectable()
export class LoginThrottlerGuard extends ThrottlerGuard {
  protected handleRequest(request: ThrottlerRequest): Promise<boolean> {
    const limit = Number(process.env.THROTTLE_LOGIN_LIMIT ?? 5);
    const ttl = Number(process.env.THROTTLE_LOGIN_TTL_SECONDS ?? 900) * 1_000;

    return super.handleRequest({
      ...request,
      limit,
      ttl,
      blockDuration: ttl,
    });
  }

  protected getTracker(req: Record<string, unknown>): Promise<string> {
    const body = req.body as LoginRequestBody | undefined;
    const email =
      typeof body?.email === 'string' ? body.email.toLowerCase() : 'unknown';
    return Promise.resolve(`${String(req.ip)}:${email}`);
  }
}
