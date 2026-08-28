import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { Device } from '../../domain/entities/device.entity';
import { DeviceNotRegisteredError } from '../../domain/errors/device-errors';
import { DEVICE_WRITER_PORT } from '../../domain/ports/device-writer.port';
import type { DeviceWriterPort } from '../../domain/ports/device-writer.port';

export interface UpdateDevicePushRegistrationInput {
  deviceId: string;
  locale?: string;
  fcmToken?: string | null;
}

@Injectable()
export class UpdateDevicePushRegistrationUseCase {
  constructor(
    @Inject(DEVICE_WRITER_PORT) private readonly writer: DeviceWriterPort,
  ) {}

  async execute(
    input: UpdateDevicePushRegistrationInput,
  ): Promise<Result<Device>> {
    let deviceId: DeviceId;
    try {
      deviceId = DeviceId.create(input.deviceId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    if (input.locale === undefined && input.fcmToken === undefined) {
      return Result.failure(
        new ValidationError('Provide locale or fcmToken to update'),
      );
    }

    if (input.locale !== undefined && !['es', 'va'].includes(input.locale)) {
      return Result.failure(new ValidationError('Unsupported device locale'));
    }

    const device = await this.writer.updatePushRegistration({
      id: deviceId,
      locale: input.locale,
      fcmToken: input.fcmToken,
    });
    return device
      ? Result.success(device)
      : Result.failure(new DeviceNotRegisteredError(input.deviceId));
  }
}
