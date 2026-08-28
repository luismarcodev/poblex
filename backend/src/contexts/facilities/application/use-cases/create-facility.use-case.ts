import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Facility } from '../../domain/entities/facility.entity';
import { FacilityForbiddenError } from '../../domain/errors/facility-errors';
import { FACILITY_WRITER_PORT } from '../../domain/ports/facility-writer.port';
import type { FacilityWriterPort } from '../../domain/ports/facility-writer.port';
import { OpeningHours } from '../../domain/value-objects/opening-hours.vo';

export interface CreateFacilityInput {
  managerId: string;
  municipalityId: string;
  name: { es?: string; va?: string };
  description?: { es?: string; va?: string };
  category: string;
  imageUrl?: string;
  slotDurationMinutes: number;
  openingHours: unknown;
  feeNote?: { es?: string; va?: string };
  maxAdvanceBookingDays: number;
}

@Injectable()
export class CreateFacilityUseCase {
  constructor(
    @Inject(FACILITY_WRITER_PORT) private readonly writer: FacilityWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: CreateFacilityInput): Promise<Result<Facility>> {
    let municipalityId: MunicipalityId;
    let name: LocalizedText;
    let openingHours: OpeningHours;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      name = LocalizedText.create(input.name);
      openingHours = OpeningHours.create(input.openingHours);

      Facility.create({
        id: 'pending',
        municipalityId,
        name,
        description: input.description
          ? LocalizedText.create(input.description)
          : null,
        category: input.category,
        imageUrl: input.imageUrl ?? null,
        slotDurationMinutes: input.slotDurationMinutes,
        openingHours,
        feeNote: input.feeNote ? LocalizedText.create(input.feeNote) : null,
        maxAdvanceBookingDays: input.maxAdvanceBookingDays,
        active: true,
        createdAt: new Date(),
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
        new FacilityForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const facility = await this.writer.create({
      municipalityId,
      name,
      description: input.description
        ? LocalizedText.create(input.description)
        : null,
      category: input.category,
      imageUrl: input.imageUrl ?? null,
      slotDurationMinutes: input.slotDurationMinutes,
      openingHours,
      feeNote: input.feeNote ? LocalizedText.create(input.feeNote) : null,
      maxAdvanceBookingDays: input.maxAdvanceBookingDays,
    });

    return Result.success(facility);
  }
}
