import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { DeviceId } from '../../../../../shared/domain/value-objects/device-id';
import { Device } from '../../../domain/entities/device.entity';
import type {
  DevicePushTarget,
  DeviceReaderPort,
} from '../../../domain/ports/device-reader.port';
import type {
  DeviceWriterPort,
  RegisterDeviceParams,
  UpdateDeviceMunicipalityParams,
  UpdateDevicePushRegistrationParams,
} from '../../../domain/ports/device-writer.port';
import { DeviceMapper } from './device.mapper';

@Injectable()
export class DevicePrismaRepository
  implements DeviceWriterPort, DeviceReaderPort
{
  constructor(private readonly prisma: PrismaService) {}

  async registerOrTouch(params: RegisterDeviceParams): Promise<Device> {
    const row = await this.prisma.device.upsert({
      where: { id: params.id.value },
      create: {
        id: params.id.value,
        municipalityId: params.municipalityId.value,
        locale: params.locale,
        fcmToken: params.fcmToken,
      },
      update: {
        locale: params.locale,
        fcmToken: params.fcmToken,
        lastSeenAt: new Date(),
      },
    });
    return DeviceMapper.toDomain(row);
  }

  async updateMunicipality(
    params: UpdateDeviceMunicipalityParams,
  ): Promise<Device | null> {
    try {
      const row = await this.prisma.device.update({
        where: { id: params.id.value },
        data: {
          municipalityId: params.municipalityId.value,
          lastSeenAt: new Date(),
        },
      });
      return DeviceMapper.toDomain(row);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2025'
      ) {
        return null;
      }
      throw error;
    }
  }

  async updatePushRegistration(
    params: UpdateDevicePushRegistrationParams,
  ): Promise<Device | null> {
    try {
      const row = await this.prisma.device.update({
        where: { id: params.id.value },
        data: {
          locale: params.locale,
          fcmToken: params.fcmToken,
          lastSeenAt: new Date(),
        },
      });
      return DeviceMapper.toDomain(row);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2025'
      ) {
        return null;
      }
      throw error;
    }
  }

  async findRegisteredAndTouch(deviceId: DeviceId): Promise<Device | null> {
    try {
      const row = await this.prisma.device.update({
        where: { id: deviceId.value },
        data: { lastSeenAt: new Date() },
      });
      return DeviceMapper.toDomain(row);
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2025'
      ) {
        return null;
      }
      throw error;
    }
  }

  async findPushTargets(deviceIds: DeviceId[]): Promise<DevicePushTarget[]> {
    if (deviceIds.length === 0) return [];

    const rows = await this.prisma.device.findMany({
      where: {
        id: { in: deviceIds.map((deviceId) => deviceId.value) },
        fcmToken: { not: null },
      },
      select: { id: true, locale: true, fcmToken: true },
    });

    return rows.map((row) => ({
      deviceId: row.id,
      locale: row.locale,
      fcmToken: row.fcmToken!,
    }));
  }

  async invalidateTokens(tokens: string[]): Promise<void> {
    if (tokens.length === 0) return;

    await this.prisma.device.updateMany({
      where: { fcmToken: { in: tokens } },
      data: { fcmToken: null },
    });
  }

  async deleteInactiveBefore(threshold: Date): Promise<number> {
    const result = await this.prisma.device.deleteMany({
      where: { lastSeenAt: { lt: threshold } },
    });
    return result.count;
  }
}
