import { ExecutionContext, createParamDecorator } from '@nestjs/common';

interface RequestWithManager {
  user?: { managerId: string };
}

// Requiere ManagerJwtAuthGuard aplicado antes en la cadena — el guard rellena
// request.user a partir del payload del JWT verificado.
export const CurrentManagerId = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): string => {
    const request = ctx.switchToHttp().getRequest<RequestWithManager>();
    if (!request.user) {
      throw new Error('CurrentManagerId used without ManagerJwtAuthGuard');
    }
    return request.user.managerId;
  },
);
