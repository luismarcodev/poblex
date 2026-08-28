import type { Device as PrismaDevice } from '@prisma/client';
import { DeviceId } from '../../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Device } from '../../../domain/entities/device.entity';

export class DeviceMapper {
  static toDomain(row: PrismaDevice): Device {
    return Device.create({
      id: DeviceId.create(row.id),
      municipalityId: MunicipalityId.create(row.municipalityId),
      locale: row.locale,
      fcmToken: row.fcmToken,
      lastSeenAt: row.lastSeenAt,
    });
  }
}
