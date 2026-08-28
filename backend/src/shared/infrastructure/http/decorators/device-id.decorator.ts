import { ExecutionContext, createParamDecorator } from '@nestjs/common';
import type { Request } from 'express';

// Extrae el valor crudo de X-Device-Id sin validar. La validación de formato
// (UUID v4) la hace el value object DeviceId en el caso de uso — este
// decorador solo transporta el dato desde HTTP hacia dentro.
export const DeviceIdHeader = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string | undefined => {
    const request = ctx.switchToHttp().getRequest<Request>();
    const header = request.headers['x-device-id'];
    return Array.isArray(header) ? header[0] : header;
  },
);
