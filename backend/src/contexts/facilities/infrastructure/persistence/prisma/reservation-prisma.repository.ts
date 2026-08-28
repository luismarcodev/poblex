import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Reservation } from '../../../domain/entities/reservation.entity';
import { ReservationCancellation } from '../../../domain/entities/reservation-cancellation.entity';
import { SlotAlreadyBookedError } from '../../../domain/errors/facility-errors';
import type {
  CancelReservationParams,
  CreateReservationParams,
  ReservationWriterPort,
} from '../../../domain/ports/reservation-writer.port';
import type {
  FindManagedReservationsParams,
  FindMyReservationsParams,
  ReservationListResult,
  ReservationReaderPort,
} from '../../../domain/ports/reservation-reader.port';
import { ReservationMapper } from './reservation.mapper';

function encodeCursor(slotStart: Date, id: string): string {
  return Buffer.from(`${slotStart.toISOString()}|${id}`).toString(
    'base64url',
  );
}

function decodeCursor(cursor: string): { slotStart: Date; id: string } {
  const [iso, id] = Buffer.from(cursor, 'base64url')
    .toString('utf-8')
    .split('|');
  return { slotStart: new Date(iso), id };
}

@Injectable()
export class ReservationPrismaRepository
  implements ReservationReaderPort, ReservationWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async findById(id: string): Promise<Reservation | null> {
    const row = await this.prisma.reservation.findUnique({ where: { id } });
    return row ? ReservationMapper.toDomain(row) : null;
  }

  async findMine(
    params: FindMyReservationsParams,
  ): Promise<ReservationListResult> {
    const cursorFilter = params.cursor
      ? (() => {
          const { slotStart, id } = decodeCursor(params.cursor!);
          return {
            OR: [
              { slotStart: { lt: slotStart } },
              { slotStart, id: { lt: id } },
            ],
          };
        })()
      : {};

    const rows = await this.prisma.reservation.findMany({
      where: { deviceId: params.deviceId, AND: [cursorFilter] },
      orderBy: [{ slotStart: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });
    return this.toListResult(rows, params.limit);
  }

  async findManaged(
    params: FindManagedReservationsParams,
  ): Promise<ReservationListResult> {
    const cursorFilter = params.cursor
      ? (() => {
          const { slotStart, id } = decodeCursor(params.cursor!);
          return {
            OR: [
              { slotStart: { lt: slotStart } },
              { slotStart, id: { lt: id } },
            ],
          };
        })()
      : {};

    const rows = await this.prisma.reservation.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        facilityId: params.facilityId,
        AND: [cursorFilter],
      },
      orderBy: [{ slotStart: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });
    return this.toListResult(rows, params.limit);
  }

  private toListResult(
    rows: Array<Parameters<typeof ReservationMapper.toDomain>[0]>,
    limit: number,
  ): ReservationListResult {
    const hasMore = rows.length > limit;
    const pageRows = hasMore ? rows.slice(0, limit) : rows;
    const lastRow = pageRows[pageRows.length - 1];
    return {
      items: pageRows.map((row) => ReservationMapper.toDomain(row)),
      nextCursor:
        hasMore && lastRow
          ? encodeCursor(lastRow.slotStart, lastRow.id)
          : null,
    };
  }

  async findByFacilityInRange(
    facilityId: string,
    rangeStart: Date,
    rangeEnd: Date,
  ): Promise<Reservation[]> {
    const rows = await this.prisma.reservation.findMany({
      where: {
        facilityId,
        slotStart: { gte: rangeStart, lt: rangeEnd },
      },
      orderBy: { slotStart: 'asc' },
    });
    return rows.map((row) => ReservationMapper.toDomain(row));
  }

  async countActiveByDeviceAndFacility(
    deviceId: string,
    facilityId: string,
    now: Date,
  ): Promise<number> {
    return this.prisma.reservation.count({
      where: { deviceId, facilityId, slotStart: { gt: now } },
    });
  }

  async create(params: CreateReservationParams): Promise<Reservation> {
    try {
      const row = await this.prisma.reservation.create({
        data: {
          facilityId: params.facilityId,
          municipalityId: params.municipalityId.value,
          deviceId: params.deviceId,
          slotStart: params.slotStart,
          slotEnd: params.slotEnd,
        },
      });
      return ReservationMapper.toDomain(row);
    } catch (error) {
      // P2002 = violación de UNIQUE (facility_id, slot_start): alguien se ha
      // adelantado por una condición de carrera entre la comprobación previa
      // y este INSERT. Se traduce a un error de dominio limpio, nunca deja
      // escapar la excepción de Prisma fuera del adaptador (mismo criterio
      // que castVote en surveys).
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new SlotAlreadyBookedError(params.facilityId, params.slotStart);
      }
      throw error;
    }
  }

  async cancel(
    params: CancelReservationParams,
  ): Promise<ReservationCancellation> {
    // Borrado + auditoría en la MISMA transacción: el hueco no puede quedar
    // libre sin que quede constancia de quién y cuándo lo canceló.
    const [, created] = await this.prisma.$transaction([
      this.prisma.reservation.delete({
        where: { id: params.reservation.id },
      }),
      this.prisma.reservationCancellation.create({
        data: {
          facilityId: params.reservation.facilityId,
          municipalityId: params.reservation.municipalityId.value,
          deviceId: params.reservation.deviceId,
          slotStart: params.reservation.slotStart,
          slotEnd: params.reservation.slotEnd,
          cancelledBy: params.cancelledBy,
          cancelNote: params.cancelNote,
        },
      }),
    ]);
    return ReservationMapper.cancellationToDomain(created);
  }
}
