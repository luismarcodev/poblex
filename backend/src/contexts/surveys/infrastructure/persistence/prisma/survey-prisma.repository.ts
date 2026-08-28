import { Injectable } from '@nestjs/common';
import { DeviceId } from '../../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Survey } from '../../../domain/entities/survey.entity';
import type {
  FindSurveysParams,
  SurveyListResult,
  SurveyOptionTally,
  SurveyReaderPort,
} from '../../../domain/ports/survey-reader.port';
import type {
  CastVoteParams,
  CreateSurveyParams,
  SurveyWriterPort,
} from '../../../domain/ports/survey-writer.port';
import { SurveyMapper } from './survey.mapper';

function encodeCursor(closesAt: Date, id: string): string {
  return Buffer.from(`${closesAt.toISOString()}|${id}`).toString('base64url');
}

function decodeCursor(cursor: string): { closesAt: Date; id: string } {
  const [iso, id] = Buffer.from(cursor, 'base64url')
    .toString('utf-8')
    .split('|');
  return { closesAt: new Date(iso), id };
}

@Injectable()
export class SurveyPrismaRepository
  implements SurveyReaderPort, SurveyWriterPort
{
  constructor(private readonly prisma: PrismaService) {}

  async find(params: FindSurveysParams): Promise<SurveyListResult> {
    const cursorFilter = params.cursor
      ? (() => {
          const { closesAt, id } = decodeCursor(params.cursor);
          return {
            OR: [{ closesAt: { gt: closesAt } }, { closesAt, id: { gt: id } }],
          };
        })()
      : {};

    const rows = await this.prisma.survey.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        closesAt: params.openAt ? { gt: params.openAt } : undefined,
        ...cursorFilter,
      },
      include: { options: true },
      // Las que cierran antes, primero: son las que urge contestar.
      orderBy: [{ closesAt: 'asc' }, { id: 'asc' }],
      take: params.limit + 1,
    });

    const hasMore = rows.length > params.limit;
    const pageRows = hasMore ? rows.slice(0, params.limit) : rows;
    const lastRow = pageRows[pageRows.length - 1];

    return {
      items: pageRows.map((row) => SurveyMapper.toDomain(row)),
      nextCursor:
        hasMore && lastRow ? encodeCursor(lastRow.closesAt, lastRow.id) : null,
    };
  }

  async findById(id: string): Promise<Survey | null> {
    const row = await this.prisma.survey.findUnique({
      where: { id },
      include: { options: true },
    });
    return row ? SurveyMapper.toDomain(row) : null;
  }

  async findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Survey | null> {
    const row = await this.prisma.survey.findFirst({
      where: { id, municipalityId: municipalityId.value },
      include: { options: true },
    });
    return row ? SurveyMapper.toDomain(row) : null;
  }

  async countVotesByOption(surveyId: string): Promise<SurveyOptionTally[]> {
    const grouped = await this.prisma.surveyVote.groupBy({
      by: ['optionId'],
      where: { surveyId },
      _count: { _all: true },
    });
    return grouped.map((group) => ({
      optionId: group.optionId,
      votes: group._count._all,
    }));
  }

  async findDeviceVote(
    surveyId: string,
    deviceId: DeviceId,
  ): Promise<{ optionId: string } | null> {
    const row = await this.prisma.surveyVote.findUnique({
      where: {
        surveyId_deviceId: { surveyId, deviceId: deviceId.value },
      },
      select: { optionId: true },
    });
    return row;
  }

  async create(params: CreateSurveyParams): Promise<Survey> {
    const row = await this.prisma.survey.create({
      data: {
        municipalityId: params.municipalityId.value,
        question: params.question.toJSON() as Prisma.InputJsonValue,
        closesAt: params.closesAt,
        resultsVisible: params.resultsVisible,
        options: {
          create: params.options.map((option) => ({
            label: option.label.toJSON() as Prisma.InputJsonValue,
            position: option.position,
          })),
        },
      },
      include: { options: true },
    });
    return SurveyMapper.toDomain(row);
  }

  async close(id: string, closesAt: Date): Promise<Survey> {
    const row = await this.prisma.survey.update({
      where: { id },
      data: { closesAt },
      include: { options: true },
    });
    return SurveyMapper.toDomain(row);
  }

  async setResultsVisible(id: string, visible: boolean): Promise<Survey> {
    const row = await this.prisma.survey.update({
      where: { id },
      data: { resultsVisible: visible },
      include: { options: true },
    });
    return SurveyMapper.toDomain(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.survey.delete({ where: { id } });
  }

  async castVote(params: CastVoteParams): Promise<boolean> {
    try {
      await this.prisma.surveyVote.create({
        data: {
          surveyId: params.surveyId,
          optionId: params.optionId,
          deviceId: params.deviceId.value,
        },
      });
      return true;
    } catch (error) {
      // P2002 = violación de UNIQUE (survey_id, device_id): este dispositivo
      // ya votó. Se traduce a un valor de dominio, no se deja escapar la
      // excepción de Prisma fuera del adaptador.
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        return false;
      }
      throw error;
    }
  }
}
