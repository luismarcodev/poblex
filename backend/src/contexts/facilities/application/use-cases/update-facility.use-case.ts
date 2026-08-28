import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Facility } from '../../domain/entities/facility.entity';
import {
  FacilityForbiddenError,
  FacilityNotFoundError,
} from '../../domain/errors/facility-errors';
import { FACILITY_READER_PORT } from '../../domain/ports/facility-reader.port';
import type { FacilityReaderPort } from '../../domain/ports/facility-reader.port';
import { FACILITY_WRITER_PORT } from '../../domain/ports/facility-writer.port';
import type {
  FacilityWriterPort,
  UpdateFacilityFields,
} from '../../domain/ports/facility-writer.port';
import { OpeningHours } from '../../domain/value-objects/opening-hours.vo';

export interface UpdateFacilityInput {
  facilityId: string;
  managerId: string;
  name?: { es?: string; va?: string };
  description?: { es?: string; va?: string } | null;
  category?: string;
  imageUrl?: string | null;
  slotDurationMinutes?: number;
  openingHours?: unknown;
  feeNote?: { es?: string; va?: string } | null;
  maxAdvanceBookingDays?: number;
  active?: boolean;
}

@Injectable()
export class UpdateFacilityUseCase {
  constructor(
    @Inject(FACILITY_READER_PORT) private readonly reader: FacilityReaderPort,
    @Inject(FACILITY_WRITER_PORT) private readonly writer: FacilityWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: UpdateFacilityInput): Promise<Result<Facility>> {
    const existing = await this.reader.findById(input.facilityId);
    if (!existing) {
      return Result.failure(new FacilityNotFoundError(input.facilityId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new FacilityForbiddenError(
          input.managerId,
          existing.municipalityId.value,
        ),
      );
    }

    let fields: UpdateFacilityFields;
    try {
      fields = {
        name: input.name ? LocalizedText.create(input.name) : undefined,
        description:
          input.description === undefined
            ? undefined
            : input.description === null
              ? null
              : LocalizedText.create(input.description),
        category: input.category,
        imageUrl: input.imageUrl,
        slotDurationMinutes: input.slotDurationMinutes,
        openingHours: input.openingHours
          ? OpeningHours.create(input.openingHours)
          : undefined,
        feeNote:
          input.feeNote === undefined
            ? undefined
            : input.feeNote === null
              ? null
              : LocalizedText.create(input.feeNote),
        maxAdvanceBookingDays: input.maxAdvanceBookingDays,
        active: input.active,
      };

      // Validación de forma completa antes de persistir: construye la
      // entidad con los valores resultantes para reutilizar las mismas
      // reglas que en la creación (duración de franja, ventana de reserva).
      Facility.create({
        id: existing.id,
        municipalityId: existing.municipalityId,
        name: fields.name ?? existing.name,
        description:
          fields.description !== undefined
            ? fields.description
            : existing.description,
        category: fields.category ?? existing.category,
        imageUrl: fields.imageUrl !== undefined ? fields.imageUrl : existing.imageUrl,
        slotDurationMinutes:
          fields.slotDurationMinutes ?? existing.slotDurationMinutes,
        openingHours: fields.openingHours ?? existing.openingHours,
        feeNote: fields.feeNote !== undefined ? fields.feeNote : existing.feeNote,
        maxAdvanceBookingDays:
          fields.maxAdvanceBookingDays ?? existing.maxAdvanceBookingDays,
        active: fields.active ?? existing.active,
        createdAt: existing.createdAt,
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const updated = await this.writer.update(input.facilityId, fields);
    return Result.success(updated);
  }
}
