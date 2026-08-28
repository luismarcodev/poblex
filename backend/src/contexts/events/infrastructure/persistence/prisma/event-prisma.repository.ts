import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { MunicipalEvent } from '../../../domain/entities/event.entity';
import type {
  EventListResult,
  EventReaderPort,
  FindUpcomingEventsParams,
} from '../../../domain/ports/event-reader.port';
import type {
  CreateEventParams,
  EventWriterPort,
  UpdateEventFields,
} from '../../../domain/ports/event-writer.port';
import { EventMapper } from './event.mapper';

// La agenda se ordena ASCENDENTE (lo próximo primero), al revés que las
// noticias: el cursor compara con `gt`, no con `lt`.
function encodeCursor(startAt: Date, id: string): string {
  return Buffer.from(`${startAt.toISOString()}|${id}`).toString('base64url');
}

function decodeCursor(cursor: string): { startAt: Date; id: string } {
  const [iso, id] = Buffer.from(cursor, 'base64url')
    .toString('utf-8')
    .split('|');
  return { startAt: new Date(iso), id };
}

@Injectable()
export class EventPrismaRepository implements EventReaderPort, EventWriterPort {
  constructor(private readonly prisma: PrismaService) {}

  async findUpcoming(
    params: FindUpcomingEventsParams,
  ): Promise<EventListResult> {
    const cursorFilter = params.cursor
      ? (() => {
          const { startAt, id } = decodeCursor(params.cursor);
          return {
            OR: [{ startAt: { gt: startAt } }, { startAt, id: { gt: id } }],
          };
        })()
      : {};

    const rows = await this.prisma.event.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        startAt: { gte: params.from },
        ...cursorFilter,
      },
      orderBy: [{ startAt: 'asc' }, { id: 'asc' }],
      take: params.limit + 1,
    });

    const hasMore = rows.length > params.limit;
    const pageRows = hasMore ? rows.slice(0, params.limit) : rows;
    const lastRow = pageRows[pageRows.length - 1];

    return {
      items: pageRows.map((row) => EventMapper.toDomain(row)),
      nextCursor:
        hasMore && lastRow ? encodeCursor(lastRow.startAt, lastRow.id) : null,
    };
  }

  async findById(id: string): Promise<MunicipalEvent | null> {
    const row = await this.prisma.event.findUnique({ where: { id } });
    return row ? EventMapper.toDomain(row) : null;
  }

  async findByIdForMunicipality(
    id: string,
    municipalityId: import('../../../../../shared/domain/value-objects/municipality-id').MunicipalityId,
  ): Promise<MunicipalEvent | null> {
    const row = await this.prisma.event.findFirst({
      where: { id, municipalityId: municipalityId.value },
    });
    return row ? EventMapper.toDomain(row) : null;
  }

  async create(params: CreateEventParams): Promise<MunicipalEvent> {
    const row = await this.prisma.event.create({
      data: {
        municipalityId: params.municipalityId.value,
        title: params.title.toJSON() as Prisma.InputJsonValue,
        description: params.description.toJSON() as Prisma.InputJsonValue,
        startAt: params.startAt,
        endAt: params.endAt,
        locationName: params.locationName,
        lat: params.lat,
        lng: params.lng,
        category: params.category.value,
      },
    });
    return EventMapper.toDomain(row);
  }

  async update(id: string, fields: UpdateEventFields): Promise<MunicipalEvent> {
    const row = await this.prisma.event.update({
      where: { id },
      data: {
        title: fields.title?.toJSON() as Prisma.InputJsonValue | undefined,
        description: fields.description?.toJSON() as
          Prisma.InputJsonValue | undefined,
        startAt: fields.startAt,
        endAt: fields.endAt,
        locationName: fields.locationName,
        lat: fields.lat,
        lng: fields.lng,
        category: fields.category?.value,
      },
    });
    return EventMapper.toDomain(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.event.delete({ where: { id } });
  }
}
