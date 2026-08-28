import { NotFoundError } from '../../../../shared/domain/errors/common-errors';

// Toda escritura del vecino exige dispositivo dado de alta previamente
// (POST /v1/devices). Sin él no hay municipio asociado y la escritura no
// tiene dónde colgarse.
export class DeviceNotRegisteredError extends NotFoundError {
  constructor(deviceId: string) {
    super(`Device not registered: ${deviceId}`);
  }
}
