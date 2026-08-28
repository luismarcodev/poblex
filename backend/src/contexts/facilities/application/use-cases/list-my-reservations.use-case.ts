import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { RESERVATION_READER_PORT } from '../../domain/ports/reservation-reader.port';
import type {
  ReservationListResult,
  ReservationReaderPort,
} from '../../domain/ports/reservation-reader.port';

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListMyReservationsUseCase {
  constructor(
    @Inject(RESERVATION_READER_PORT)
    private readonly reader: ReservationReaderPort,
  ) {}

  async execute(
    deviceId: string | undefined,
    cursor?: string,
    limit?: number,
  ): Promise<Result<ReservationListResult>> {
    let validDeviceId: DeviceId;
    try {
      validDeviceId = DeviceId.create(deviceId ?? '');
    } catch (error) {
      return Result.failure(error as ValidationError);
    }

    const result = await this.reader.findMine({
      deviceId: validDeviceId.value,
      cursor,
      limit: Math.min(limit ?? DEFAULT_LIMIT, MAX_LIMIT),
    });
    return Result.success(result);
  }
}
