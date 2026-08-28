import { SetMetadata } from '@nestjs/common';

export interface DeviceThrottleOptions {
  limit: number;
  ttl: number;
}

export const DEVICE_THROTTLE_METADATA = 'poblex:device-throttle';

export const DeviceThrottle = (
  options: DeviceThrottleOptions,
): MethodDecorator => SetMetadata(DEVICE_THROTTLE_METADATA, options);
