import { Injectable } from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import type { ThrottlerRequest } from '@nestjs/throttler/dist/throttler.guard.interface';
import {
  DEVICE_THROTTLE_METADATA,
  type DeviceThrottleOptions,
} from './decorators/device-throttle.decorator';

// Límite de escrituras públicas por DISPOSITIVO además de por IP.
//
// El X-Device-Id es falsificable y no protege nada por sí solo, así que el
// tracker combina IP y dispositivo: rotar solo el UUID no esquiva el límite
// mientras la IP no cambie, y dos vecinos tras el mismo NAT no se bloquean
// entre sí. La barrera contra la creación masiva de dispositivos falsos es el
// límite por IP del guard global.
@Injectable()
export class DeviceThrottlerGuard extends ThrottlerGuard {
  protected handleRequest(request: ThrottlerRequest): Promise<boolean> {
    const options = this.reflector.getAllAndOverride<DeviceThrottleOptions>(
      DEVICE_THROTTLE_METADATA,
      [request.context.getHandler(), request.context.getClass()],
    );

    return super.handleRequest(
      options
        ? {
            ...request,
            limit: options.limit,
            ttl: options.ttl,
            blockDuration: options.ttl,
          }
        : request,
    );
  }

  protected getTracker(req: Record<string, unknown>): Promise<string> {
    const headers = req.headers as
      Record<string, string | string[]> | undefined;
    const raw = headers?.['x-device-id'];
    const deviceId = Array.isArray(raw) ? raw[0] : (raw ?? 'unknown');
    return Promise.resolve(`${String(req.ip)}:${deviceId}`);
  }
}
