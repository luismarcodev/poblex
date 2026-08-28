import { Inject, Injectable } from '@nestjs/common';
import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { NotifyDevicesService } from '../../../devices/application/services/notify-devices.service';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { ReservationCancellation } from '../../domain/entities/reservation-cancellation.entity';
import {
  FacilityForbiddenError,
  ReservationNotFoundError,
} from '../../domain/errors/facility-errors';
import { FACILITY_READER_PORT } from '../../domain/ports/facility-reader.port';
import type { FacilityReaderPort } from '../../domain/ports/facility-reader.port';
import { RESERVATION_READER_PORT } from '../../domain/ports/reservation-reader.port';
import type { ReservationReaderPort } from '../../domain/ports/reservation-reader.port';
import { RESERVATION_WRITER_PORT } from '../../domain/ports/reservation-writer.port';
import type { ReservationWriterPort } from '../../domain/ports/reservation-writer.port';

export interface CancelReservationAsManagerInput {
  reservationId: string;
  managerId: string;
  note: string;
}

@Injectable()
export class CancelReservationAsManagerUseCase {
  constructor(
    @Inject(RESERVATION_READER_PORT)
    private readonly reservationReader: ReservationReaderPort,
    @Inject(RESERVATION_WRITER_PORT)
    private readonly reservationWriter: ReservationWriterPort,
    @Inject(FACILITY_READER_PORT)
    private readonly facilities: FacilityReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly notifyDevices: NotifyDevicesService,
  ) {}

  async execute(
    input: CancelReservationAsManagerInput,
  ): Promise<Result<ReservationCancellation>> {
    if (!input.note.trim()) {
      return Result.failure(
        new ValidationError('A cancellation note is required'),
      );
    }

    const reservation = await this.reservationReader.findById(
      input.reservationId,
    );
    if (!reservation) {
      return Result.failure(new ReservationNotFoundError(input.reservationId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      reservation.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new FacilityForbiddenError(
          input.managerId,
          reservation.municipalityId.value,
        ),
      );
    }

    const cancellation = await this.reservationWriter.cancel({
      reservation,
      cancelledBy: input.managerId,
      cancelNote: input.note.trim(),
    });

    const facility = await this.facilities.findById(reservation.facilityId);
    const facilityName = facility?.name.resolve('es').text ?? 'la instalación';
    // Dirigido por token al dispositivo afectado, en SU idioma — nunca por
    // topic, mismo criterio que el cambio de estado de una incidencia.
    await this.notifyDevices.notify([DeviceId.create(reservation.deviceId)], {
      title: {
        es: 'Reserva cancelada',
        va: 'Reserva cancel·lada',
      },
      body: {
        es: `Tu reserva de ${facilityName} ha sido cancelada por el ayuntamiento. Motivo: ${input.note.trim()}`,
        va: `La teua reserva de ${facilityName} ha sigut cancel·lada per l'ajuntament. Motiu: ${input.note.trim()}`,
      },
      data: {
        type: 'reservation_cancelled',
        id: reservation.id,
        facilityId: reservation.facilityId,
      },
    });

    return Result.success(cancellation);
  }
}
