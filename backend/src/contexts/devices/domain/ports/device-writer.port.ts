import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Device } from '../entities/device.entity';

export interface RegisterDeviceParams {
  id: DeviceId;
  municipalityId: MunicipalityId;
  locale: string;
  fcmToken?: string;
}

export interface UpdateDeviceMunicipalityParams {
  id: DeviceId;
  municipalityId: MunicipalityId;
}

export interface UpdateDevicePushRegistrationParams {
  id: DeviceId;
  locale?: string;
  fcmToken?: string | null;
}

export interface DeviceWriterPort {
  // Alta si no existe; si ya existe, actualiza locale/fcmToken/lastSeenAt.
  // El cambio de municipio NO ocurre aquí — solo vía updateMunicipality.
  registerOrTouch(params: RegisterDeviceParams): Promise<Device>;

  // null si el dispositivo no existe (el caso de uso lo traduce a 404).
  updateMunicipality(
    params: UpdateDeviceMunicipalityParams,
  ): Promise<Device | null>;
  updatePushRegistration(
    params: UpdateDevicePushRegistrationParams,
  ): Promise<Device | null>;
}

export const DEVICE_WRITER_PORT = Symbol('DEVICE_WRITER_PORT');
