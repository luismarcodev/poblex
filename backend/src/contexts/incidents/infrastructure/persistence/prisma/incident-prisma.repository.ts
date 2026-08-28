import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { IncidentStatusChange } from '../../../domain/entities/incident-status-change.entity';
import { Incident } from '../../../domain/entities/incident.entity';
import type {
  FindDeviceIncidentsParams,
  FindManagerIncidentsParams,
  IncidentListResult,
  IncidentReaderPort,
} from '../../../domain/ports/incident-reader.port';
import type {
  ChangeStatusParams,
  CreateIncidentParams,
  IncidentWriterPort,
  PurgeablePhoto,
} from '../../../domain/ports/incident-writer.port';
import { IncidentMapper } from './incident.mapper';

function encodeCursor(createdAt: Date, id: string): string {
  return Buffer.from(`${createdAt.toISOString()}|${id}`).toString('base64url');
}

function decodeCursor(cursor: string): { createdAt: Date; id: string } {
  const [iso, id] = Buffer.from(cursor, 'base64url')
    .toString('utf-8')
    .split('|');
  return { createdAt: new Date(iso), id };
}

function cursorFilter(cursor?: string) {
  if (!cursor) return {};
  const { createdAt, id } = decodeCursor(cursor);
  return {
    OR: [{ createdAt: { lt: createdAt } }, { createdAt, id: { lt: id } }],
  };
}

@Injectable()
export class IncidentPrismaRepository
  implements IncidentReaderPort, IncidentWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async findByDevice(
    params: FindDeviceIncidentsParams,
  ): Promise<IncidentListResult> {
    const rows = await this.prisma.incident.findMany({
      where: {
        deviceId: params.deviceId.value,
        ...cursorFilter(params.cursor),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });
    return this.toListResult(rows, params.limit);
  }

  async findForManager(
    params: FindManagerIncidentsParams,
  ): Promise<IncidentListResult> {
    const rows = await this.prisma.incident.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        status: params.status
          ? IncidentMapper.toPrismaStatus(params.status)
          : undefined,
        category: params.category,
        ...cursorFilter(params.cursor),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });
    return this.toListResult(rows, params.limit);
  }

  async findById(id: string): Promise<Incident | null> {
    const row = await this.prisma.incident.findUnique({ where: { id } });
    return row ? IncidentMapper.toDomain(row) : null;
  }

  async findStatusHistory(incidentId: string): Promise<IncidentStatusChange[]> {
    const rows = await this.prisma.incidentStatusHistory.findMany({
      where: { incidentId },
      orderBy: { changedAt: 'asc' },
    });
    return rows.map((row) => IncidentMapper.historyToDomain(row));
  }

  async create(params: CreateIncidentParams): Promise<Incident> {
    const row = await this.prisma.incident.create({
      data: {
        municipalityId: params.municipalityId.value,
        deviceId: params.deviceId.value,
        category: params.category,
        description: params.description,
        photoUrl: params.photoUrl,
        lat: params.lat,
        lng: params.lng,
      },
    });
    return IncidentMapper.toDomain(row);
  }

  async changeStatus(params: ChangeStatusParams): Promise<Incident> {
    // Estado e historial en la MISMA transacción: un cambio de estado sin su
    // entrada de auditoría no puede existir.
    const [updated] = await this.prisma.$transaction([
      this.prisma.incident.update({
        where: { id: params.incidentId },
        data: {
          status: IncidentMapper.toPrismaStatus(params.status),
          photoPurgeAt: params.photoPurgeAt,
        },
      }),
      this.prisma.incidentStatusHistory.create({
        data: {
          incidentId: params.incidentId,
          status: IncidentMapper.toPrismaStatus(params.status),
          note: params.note,
          changedBy: params.changedBy,
        },
      }),
    ]);
    return IncidentMapper.toDomain(updated);
  }

  async attachPhoto(incidentId: string, photoUrl: string): Promise<Incident> {
    const row = await this.prisma.incident.update({
      where: { id: incidentId },
      data: { photoUrl },
    });
    return IncidentMapper.toDomain(row);
  }

  async findPhotosToPurge(
    before: Date,
    limit: number,
  ): Promise<PurgeablePhoto[]> {
    const rows = await this.prisma.incident.findMany({
      where: {
        photoPurgeAt: { lte: before },
        photoUrl: { not: null },
      },
      select: { id: true, photoUrl: true },
      take: limit,
    });
    return rows.map((row) => ({
      incidentId: row.id,
      photoUrl: row.photoUrl!,
    }));
  }

  async clearPhoto(incidentId: string): Promise<void> {
    await this.prisma.incident.update({
      where: { id: incidentId },
      data: { photoUrl: null, photoPurgeAt: null },
    });
  }

  private toListResult(
    rows: Array<Parameters<typeof IncidentMapper.toDomain>[0]>,
    limit: number,
  ): IncidentListResult {
    const hasMore = rows.length > limit;
    const pageRows = hasMore ? rows.slice(0, limit) : rows;
    const lastRow = pageRows[pageRows.length - 1];

    return {
      items: pageRows.map((row) => IncidentMapper.toDomain(row)),
      nextCursor:
        hasMore && lastRow ? encodeCursor(lastRow.createdAt, lastRow.id) : null,
    };
  }
}
