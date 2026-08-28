import { Inject, Injectable } from '@nestjs/common';
import { GetActiveMunicipalityByIdUseCase } from '../../../municipalities/application/use-cases/get-active-municipality-by-id.use-case';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Device } from '../../domain/entities/device.entity';
import { DEVICE_WRITER_PORT } from '../../domain/ports/device-writer.port';
import type { DeviceWriterPort } from '../../domain/ports/device-writer.port';

export interface RegisterDeviceInput {
  deviceId: string;
  municipalityId: string;
  locale: string;
  fcmToken?: string;
}

@Injectable()
export class RegisterDeviceUseCase {
  constructor(
    @Inject(DEVICE_WRITER_PORT) private readonly writer: DeviceWriterPort,
    private readonly getActiveMunicipalityById: GetActiveMunicipalityByIdUseCase,
  ) {}

  async execute(input: RegisterDeviceInput): Promise<Result<Device>> {
    let deviceId: DeviceId;
    let municipalityId: MunicipalityId;
    try {
      deviceId = DeviceId.create(input.deviceId);
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    if (!['es', 'va'].includes(input.locale)) {
      return Result.failure(new ValidationError('Unsupported device locale'));
    }

    const municipalityResult = await this.getActiveMunicipalityById.execute(
      municipalityId.value,
    );
    if (municipalityResult.isFailure)
      return Result.failure(municipalityResult.error);

    const device = await this.writer.registerOrTouch({
      id: deviceId,
      municipalityId,
      locale: input.locale,
      fcmToken: input.fcmToken,
    });
    return Result.success(device);
  }
}
