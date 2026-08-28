import { Body, Controller, Param, Patch, Post } from '@nestjs/common';
import { ApiHeader, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { RegisterDeviceUseCase } from '../../application/use-cases/register-device.use-case';
import { UpdateDeviceMunicipalityUseCase } from '../../application/use-cases/update-device-municipality.use-case';
import { UpdateDevicePushRegistrationUseCase } from '../../application/use-cases/update-device-push-registration.use-case';
import { Device } from '../../domain/entities/device.entity';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DeviceIdHeader } from '../../../../shared/infrastructure/http/decorators/device-id.decorator';
import { DeviceResponseDto } from './dto/device-response.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateDeviceMunicipalityDto } from './dto/update-device-municipality.dto';
import { UpdateDevicePushRegistrationDto } from './dto/update-device-push-registration.dto';

function toResponseDto(device: Device): DeviceResponseDto {
  return {
    id: device.id.value,
    municipalityId: device.municipalityId.value,
    locale: device.locale,
  };
}

@ApiTags('devices')
@Controller('devices')
export class DevicesController {
  constructor(
    private readonly registerDevice: RegisterDeviceUseCase,
    private readonly updateDeviceMunicipality: UpdateDeviceMunicipalityUseCase,
    private readonly updateDevicePushRegistration: UpdateDevicePushRegistrationUseCase,
  ) {}

  @Post()
  @Throttle({ default: { limit: 10, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  async register(
    @DeviceIdHeader() deviceId: string | undefined,
    @Body() dto: RegisterDeviceDto,
  ): Promise<DeviceResponseDto> {
    if (!deviceId) {
      throw new ValidationError('Missing X-Device-Id header');
    }

    const result = await this.registerDevice.execute({
      deviceId,
      municipalityId: dto.municipalityId,
      locale: dto.locale,
      fcmToken: dto.fcmToken,
    });
    if (result.isFailure) throw result.error;
    return toResponseDto(result.value);
  }

  // Mismo límite que el alta: cambiar de municipio es una escritura pública y
  // el identificador de dispositivo es falsificable.
  @Patch(':id')
  @Throttle({ default: { limit: 10, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  async updateMunicipality(
    @Param('id') id: string,
    @DeviceIdHeader() headerDeviceId: string | undefined,
    @Body() dto: UpdateDeviceMunicipalityDto,
  ): Promise<DeviceResponseDto> {
    if (!headerDeviceId || headerDeviceId !== id) {
      throw new ValidationError('X-Device-Id must match the path device id');
    }
    const result = await this.updateDeviceMunicipality.execute({
      deviceId: id,
      municipalityId: dto.municipalityId,
    });
    if (result.isFailure) throw result.error;
    return toResponseDto(result.value);
  }

  @Patch(':id/push')
  @Throttle({ default: { limit: 10, ttl: 3_600_000 } })
  @ApiHeader({ name: 'X-Device-Id', required: true })
  async updatePushRegistration(
    @Param('id') id: string,
    @DeviceIdHeader() headerDeviceId: string | undefined,
    @Body() dto: UpdateDevicePushRegistrationDto,
  ): Promise<DeviceResponseDto> {
    if (!headerDeviceId || headerDeviceId !== id) {
      throw new ValidationError('X-Device-Id must match the path device id');
    }
    const result = await this.updateDevicePushRegistration.execute({
      deviceId: id,
      locale: dto.locale,
      fcmToken: dto.fcmToken,
    });
    if (result.isFailure) throw result.error;
    return toResponseDto(result.value);
  }
}
