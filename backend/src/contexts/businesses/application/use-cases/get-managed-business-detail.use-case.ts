import { Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { Business } from '../../domain/entities/business.entity';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

@Injectable()
export class GetManagedBusinessDetailUseCase {
  constructor(
    private readonly authorization: AuthorizeBusinessMutationService,
  ) {}

  execute(businessId: string, managerId: string): Promise<Result<Business>> {
    return this.authorization.ensureMutable(businessId, managerId);
  }
}
