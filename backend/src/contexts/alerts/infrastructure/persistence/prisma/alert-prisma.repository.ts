import { Injectable } from '@nestjs/common';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Alert } from '../../../domain/entities/alert.entity';
import type {
  AlertListResult,
  AlertReaderPort,
  FindAlertsParams,
} from '../../../domain/ports/alert-reader.port';
import type {
  AlertWriterPort,
  CreateAlertParams,
  UpdateAlertFields,
} from '../../../domain/ports/alert-writer.port';
import { AlertMapper } from './alert.mapper';

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
export class AlertPrismaRepository implements AlertReaderPort, AlertWriterPort {
  constructor(private readonly prisma: PrismaService) {}

  async find(params: FindAlertsParams): Promise<AlertListResult> {
    // Vigente = ya empezó y no ha terminado. Sin fecha de fin se considera
    // vigente hasta que alguien la cierre.
    const activeFilter = params.activeAt
      ? {
          startAt: { lte: params.activeAt },
          OR: [{ endAt: null }, { endAt: { gte: params.activeAt } }],
        }
      : {};

    const cursorFilter = params.cursor
      ? (() => {
          const { startAt, id } = decodeCursor(params.cursor);
          return {
            OR: [{ startAt: { lt: startAt } }, { startAt, id: { lt: id } }],
          };
        })()
      : {};

    const rows = await this.prisma.alert.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        // Los dos filtros usan `OR`: van dentro de un `AND` explícito para
        // que no se pisen entre ellos al fusionar el objeto.
        AND: [activeFilter, cursorFilter],
      },
      orderBy: [{ startAt: 'desc' }, { id: 'desc' }],
      take: params.limit + 1,
    });

    const hasMore = rows.length > params.limit;
    const pageRows = hasMore ? rows.slice(0, params.limit) : rows;
    const lastRow = pageRows[pageRows.length - 1];

    return {
      items: pageRows.map((row) => AlertMapper.toDomain(row)),
      nextCursor:
        hasMore && lastRow ? encodeCursor(lastRow.startAt, lastRow.id) : null,
    };
  }

  async findById(id: string): Promise<Alert | null> {
    const row = await this.prisma.alert.findUnique({ where: { id } });
    return row ? AlertMapper.toDomain(row) : null;
  }

  async findByIdForMunicipality(
    id: string,
    municipalityId: import('../../../../../shared/domain/value-objects/municipality-id').MunicipalityId,
  ): Promise<Alert | null> {
    const row = await this.prisma.alert.findFirst({
      where: { id, municipalityId: municipalityId.value },
    });
    return row ? AlertMapper.toDomain(row) : null;
  }

  async create(params: CreateAlertParams): Promise<Alert> {
    const row = await this.prisma.alert.create({
      data: {
        municipalityId: params.municipalityId.value,
        source: AlertMapper.toPrismaSource(params.source),
        severity: AlertMapper.toPrismaSeverity(params.severity),
        phenomenonType: AlertMapper.toPrismaPhenomenonType(
          params.phenomenonType,
        ),
        phenomenon: params.phenomenon,
        body: params.body.toJSON() as Prisma.InputJsonValue,
        startAt: params.startAt,
        endAt: params.endAt,
        aemetId: params.aemetId,
        createdBy: params.createdBy,
      },
    });
    return AlertMapper.toDomain(row);
  }

  async update(id: string, fields: UpdateAlertFields): Promise<Alert> {
    const row = await this.prisma.alert.update({
      where: { id },
      data: {
        severity: fields.severity
          ? AlertMapper.toPrismaSeverity(fields.severity)
          : undefined,
        phenomenonType: fields.phenomenonType
          ? AlertMapper.toPrismaPhenomenonType(fields.phenomenonType)
          : undefined,
        phenomenon: fields.phenomenon,
        body: fields.body?.toJSON() as Prisma.InputJsonValue | undefined,
        startAt: fields.startAt,
        endAt: fields.endAt,
        updatedBy: fields.updatedBy,
      },
    });
    return AlertMapper.toDomain(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.alert.delete({ where: { id } });
  }

  async existsByAemetId(
    municipalityId: MunicipalityId,
    aemetId: string,
  ): Promise<boolean> {
    const row = await this.prisma.alert.findUnique({
      where: {
        municipalityId_aemetId: {
          municipalityId: municipalityId.value,
          aemetId,
        },
      },
      select: { id: true },
    });
    return row !== null;
  }
}
