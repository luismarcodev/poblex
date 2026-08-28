import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { ReservationCancellation } from '../../domain/entities/reservation-cancellation.entity';
import {
  ReservationNotFoundError,
  ReservationNotOwnedError,
} from '../../domain/errors/facility-errors';
import { RESERVATION_READER_PORT } from '../../domain/ports/reservation-reader.port';
import type { ReservationReaderPort } from '../../domain/ports/reservation-reader.port';
import { RESERVATION_WRITER_PORT } from '../../domain/ports/reservation-writer.port';
import type { ReservationWriterPort } from '../../domain/ports/reservation-writer.port';

export interface CancelReservationInput {
  reservationId: string;
  deviceId: string;
}

// El vecino cancela su propia reserva — sin nota, sin aviso push (el
// dispositivo que cancela ya sabe que ha cancelado). Comparar con
// cancel-reservation-as-manager.use-case.ts, que exige autorización de
// gestor, nota, y sí notifica al dispositivo afectado.
@Injectable()
export class CancelReservationUseCase {
  constructor(
    @Inject(RESERVATION_READER_PORT)
    private readonly reader: ReservationReaderPort,
    @Inject(RESERVATION_WRITER_PORT)
    private readonly writer: ReservationWriterPort,
  ) {}

  async execute(
    input: CancelReservationInput,
  ): Promise<Result<ReservationCancellation>> {
    const reservation = await this.reader.findById(input.reservationId);
    if (!reservation) {
      return Result.failure(new ReservationNotFoundError(input.reservationId));
    }
    if (!reservation.isOwnedBy(input.deviceId)) {
      return Result.failure(
        new ReservationNotOwnedError(input.reservationId),
      );
    }

    const cancellation = await this.writer.cancel({
      reservation,
      cancelledBy: null,
      cancelNote: null,
    });
    return Result.success(cancellation);
  }
}
