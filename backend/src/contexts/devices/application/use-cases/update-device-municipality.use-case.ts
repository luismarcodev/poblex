import { Inject, Injectable } from '@nestjs/common';
import { GetActiveMunicipalityByIdUseCase } from '../../../municipalities/application/use-cases/get-active-municipality-by-id.use-case';
import { NotFoundError } from '../../../../shared/domain/errors/common-errors';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Device } from '../../domain/entities/device.entity';
import { DEVICE_WRITER_PORT } from '../../domain/ports/device-writer.port';
import type { DeviceWriterPort } from '../../domain/ports/device-writer.port';

export interface UpdateDeviceMunicipalityInput {
  deviceId: string;
  municipalityId: string;
}

@Injectable()
export class UpdateDeviceMunicipalityUseCase {
  constructor(
    @Inject(DEVICE_WRITER_PORT) private readonly writer: DeviceWriterPort,
    private readonly getActiveMunicipalityById: GetActiveMunicipalityByIdUseCase,
  ) {}

  async execute(input: UpdateDeviceMunicipalityInput): Promise<Result<Device>> {
    let deviceId: DeviceId;
    let municipalityId: MunicipalityId;
    try {
      deviceId = DeviceId.create(input.deviceId);
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const municipalityResult = await this.getActiveMunicipalityById.execute(
      municipalityId.value,
    );
    if (municipalityResult.isFailure)
      return Result.failure(municipalityResult.error);

    const device = await this.writer.updateMunicipality({
      id: deviceId,
      municipalityId,
    });
    if (!device) {
      return Result.failure(
        new NotFoundError(`Device not found: ${input.deviceId}`),
      );
    }
    return Result.success(device);
  }
}
