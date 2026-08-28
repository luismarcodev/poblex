import { Inject, Injectable } from '@nestjs/common';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Business } from '../../domain/entities/business.entity';
import { BusinessForbiddenError } from '../../domain/errors/business-errors';
import { BUSINESS_WRITER_PORT } from '../../domain/ports/business-writer.port';
import type { BusinessWriterPort } from '../../domain/ports/business-writer.port';
import { BusinessCategory } from '../../domain/value-objects/business-category.vo';

export interface CreateBusinessInput {
  managerId: string;
  // Un único municipio: a diferencia de noticias, un comercio no se
  // co-publica en varios pueblos a la vez.
  municipalityId: string;
  name: string;
  category: string;
  description?: { es?: string; va?: string };
  address?: string;
  phone?: string;
  email?: string;
  website?: string;
  schedule?: string;
}

@Injectable()
export class CreateBusinessUseCase {
  constructor(
    @Inject(BUSINESS_WRITER_PORT) private readonly writer: BusinessWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: CreateBusinessInput): Promise<Result<Business>> {
    let municipalityId: MunicipalityId;
    let category: BusinessCategory;
    let description: LocalizedText | undefined;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      category = BusinessCategory.create(input.category);
      description = input.description
        ? LocalizedText.create(input.description)
        : undefined;

      // Invariante de la entidad (nombre no vacío) antes de escribir.
      Business.create({
        id: 'pending',
        municipalityId,
        name: input.name,
        category,
        description: description ?? null,
        address: input.address ?? null,
        phone: input.phone ?? null,
        email: input.email ?? null,
        website: input.website ?? null,
        schedule: input.schedule ?? null,
        active: true,
        createdAt: new Date(),
        photos: [],
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new BusinessForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const business = await this.writer.create({
      municipalityId,
      name: input.name,
      category,
      description,
      address: input.address,
      phone: input.phone,
      email: input.email,
      website: input.website,
      schedule: input.schedule,
    });
    return Result.success(business);
  }
}
