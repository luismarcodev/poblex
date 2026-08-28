import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { Business } from '../../domain/entities/business.entity';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type {
  BusinessWriterPort,
  UpdateBusinessFields,
} from '../../domain/ports/business-writer.port';
import { BusinessCategory } from '../../domain/value-objects/business-category.vo';
import { AuthorizeBusinessMutationService } from '../services/authorize-business-mutation.service';

export interface UpdateBusinessInput {
  id: string;
  managerId: string;
  name?: string;
  category?: string;
  // undefined keeps the current value; null clears it explicitly.
  description?: { es?: string; va?: string } | null;
  address?: string | null;
  phone?: string | null;
  email?: string | null;
  website?: string | null;
  schedule?: string | null;
}

@Injectable()
export class UpdateBusinessUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    private readonly authorize: AuthorizeBusinessMutationService,
  ) {}

  async execute(input: UpdateBusinessInput): Promise<Result<Business>> {
    const authResult = await this.authorize.ensureMutable(
      input.id,
      input.managerId,
    );
    if (authResult.isFailure) return Result.failure(authResult.error);

    let fields: UpdateBusinessFields;
    try {
      if (input.name !== undefined && input.name.trim().length === 0) {
        throw new ValidationError('Business.name must not be empty');
      }
      fields = {
        name: input.name,
        category: input.category
          ? BusinessCategory.create(input.category)
          : undefined,
        description:
          input.description === undefined
            ? undefined
            : input.description === null
              ? null
              : LocalizedText.create(input.description),
        address: input.address,
        phone: input.phone,
        email: input.email,
        website: input.website,
        schedule: input.schedule,
      };
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const updated = await this.writer.update(input.id, fields);
    return Result.success(updated);
  }
}
