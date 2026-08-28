import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { normalizeCategorySlug } from '../../../../shared/domain/value-objects/category-slug';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { GetActiveMunicipalityByIdUseCase } from '../../../municipalities/application/use-cases/get-active-municipality-by-id.use-case';
import { Incident } from '../../domain/entities/incident.entity';
import { INCIDENT_WRITER_PORT } from '../../domain/ports/incident-writer.port';
import type { IncidentWriterPort } from '../../domain/ports/incident-writer.port';
import { IncidentStatus } from '../../domain/value-objects/incident-status.vo';

export interface ReportIncidentInput {
  deviceId: string | undefined;
  municipalityId: string;
  category: string;
  description: string;
  lat?: number;
  lng?: number;
}

@Injectable()
export class ReportIncidentUseCase {
  constructor(
    @Inject(INCIDENT_WRITER_PORT) private readonly writer: IncidentWriterPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
    private readonly getActiveMunicipalityById: GetActiveMunicipalityByIdUseCase,
  ) {}

  async execute(input: ReportIncidentInput): Promise<Result<Incident>> {
    const device = await this.requireDevice.ensure(input.deviceId);
    if (device.isFailure) return Result.failure(device.error);

    let municipalityId: MunicipalityId;
    let category: string;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      if (!municipalityId.equals(device.value.municipalityId)) {
        return Result.failure(
          new ValidationError(
            'Incident municipality does not match the registered device municipality',
          ),
        );
      }
      category = normalizeCategorySlug(input.category, 'IncidentCategory');

      // Invariantes de la entidad antes de tocar la base de datos.
      Incident.create({
        id: 'pending',
        municipalityId,
        deviceId: device.value.id,
        category,
        description: input.description,
        photoUrl: null,
        photoPurgeAt: null,
        lat: input.lat ?? null,
        lng: input.lng ?? null,
        status: IncidentStatus.received(),
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const municipality = await this.getActiveMunicipalityById.execute(
      municipalityId.value,
    );
    if (municipality.isFailure) return Result.failure(municipality.error);

    const incident = await this.writer.create({
      municipalityId,
      deviceId: device.value.id,
      category,
      description: input.description,
      photoUrl: null,
      lat: input.lat ?? null,
      lng: input.lng ?? null,
    });
    return Result.success(incident);
  }
}
