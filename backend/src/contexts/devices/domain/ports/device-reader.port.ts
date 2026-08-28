import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { Device } from '../entities/device.entity';

// Destino de un push dirigido: token + idioma del dispositivo. El envío por
// token es el único que permite mandar el aviso en el idioma del vecino.
export interface DevicePushTarget {
  deviceId: string;
  locale: string;
  fcmToken: string;
}

export interface DeviceReaderPort {
  // El alta de dispositivo es obligatoria ANTES de cualquier escritura del
  // vecino (voto, incidencia, recordatorio, formulario): sin dispositivo no
  // hay municipio asociado y la escritura no tiene dónde colgarse.
  // Reads the registered device and records real activity atomically. Returning
  // the full entity is essential: every public write must compare the device's
  // municipality with the target content's municipality.
  findRegisteredAndTouch(deviceId: DeviceId): Promise<Device | null>;

  // Solo dispositivos con token vivo: los que no lo tienen no son destino.
  findPushTargets(deviceIds: DeviceId[]): Promise<DevicePushTarget[]>;

  // Limpieza de tokens rechazados por FCM.
  invalidateTokens(tokens: string[]): Promise<void>;

  // Limpieza semanal de dispositivos inactivos. Devuelve cuántos borró.
  deleteInactiveBefore(threshold: Date): Promise<number>;
}

export const DEVICE_READER_PORT = Symbol('DEVICE_READER_PORT');
