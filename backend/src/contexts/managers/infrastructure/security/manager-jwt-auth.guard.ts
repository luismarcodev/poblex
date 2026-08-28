import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

// Protege /v1/admin/**. Requiere Authorization: Bearer <accessToken>.
@Injectable()
export class ManagerJwtAuthGuard extends AuthGuard('manager-jwt') {}
