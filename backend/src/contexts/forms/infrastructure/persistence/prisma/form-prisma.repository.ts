import { Injectable } from '@nestjs/common';
import { DeviceId } from '../../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../../shared/domain/value-objects/municipality-id';
import { Prisma } from '../../../../../shared/infrastructure/prisma/prisma-client';
import { PrismaService } from '../../../../../shared/infrastructure/prisma/prisma.service';
import { Form } from '../../../domain/entities/form.entity';
import type {
  FindFormsParams,
  FormListResult,
  FormReaderPort,
  SubmissionExportRow,
} from '../../../domain/ports/form-reader.port';
import type {
  CreateFormParams,
  FormWriterPort,
  SubmitFormParams,
} from '../../../domain/ports/form-writer.port';
import { FormMapper } from './form.mapper';

// Paginación por id y no por fecha límite: `deadline` es opcional, y ordenar
// por una columna que puede ser NULL obliga a un cursor compuesto con caso
// especial para los nulos. Los formularios activos son pocos por diseño, así
// que el orden estable por id basta.
function encodeCursor(id: string): string {
  return Buffer.from(id).toString('base64url');
}

function decodeCursor(cursor: string): string {
  return Buffer.from(cursor, 'base64url').toString('utf-8');
}

@Injectable()
export class FormPrismaRepository implements FormReaderPort, FormWriterPort {
  constructor(private readonly prisma: PrismaService) {}

  async find(params: FindFormsParams): Promise<FormListResult> {
    const rows = await this.prisma.form.findMany({
      where: {
        municipalityId: params.municipalityId.value,
        // Abierto = sin plazo, o con plazo aún por vencer.
        ...(params.openAt
          ? { OR: [{ deadline: null }, { deadline: { gt: params.openAt } }] }
          : {}),
        ...(params.cursor ? { id: { gt: decodeCursor(params.cursor) } } : {}),
      },
      include: { fields: true },
      orderBy: { id: 'asc' },
      take: params.limit + 1,
    });

    const hasMore = rows.length > params.limit;
    const pageRows = hasMore ? rows.slice(0, params.limit) : rows;
    const lastRow = pageRows[pageRows.length - 1];

    return {
      items: pageRows.map((row) => FormMapper.toDomain(row)),
      nextCursor: hasMore && lastRow ? encodeCursor(lastRow.id) : null,
    };
  }

  async findById(id: string): Promise<Form | null> {
    const row = await this.prisma.form.findUnique({
      where: { id },
      include: { fields: true },
    });
    return row ? FormMapper.toDomain(row) : null;
  }

  async findByIdForMunicipality(
    id: string,
    municipalityId: MunicipalityId,
  ): Promise<Form | null> {
    const row = await this.prisma.form.findFirst({
      where: { id, municipalityId: municipalityId.value },
      include: { fields: true },
    });
    return row ? FormMapper.toDomain(row) : null;
  }

  async hasSubmitted(formId: string, deviceId: DeviceId): Promise<boolean> {
    const row = await this.prisma.formSubmission.findUnique({
      where: {
        formId_deviceId: { formId, deviceId: deviceId.value },
      },
      select: { id: true },
    });
    return row !== null;
  }

  async findSubmissionsForExport(
    formId: string,
  ): Promise<SubmissionExportRow[]> {
    const rows = await this.prisma.formSubmission.findMany({
      where: { formId },
      include: { answers: true },
      orderBy: { submittedAt: 'asc' },
    });

    return rows.map((row) => ({
      submittedAt: row.submittedAt,
      valuesByFieldId: new Map(
        row.answers.map((answer) => [answer.fieldId, answer.value]),
      ),
    }));
  }

  async create(params: CreateFormParams): Promise<Form> {
    const row = await this.prisma.form.create({
      data: {
        municipalityId: params.municipalityId.value,
        title: params.title.toJSON() as Prisma.InputJsonValue,
        description: params.description.toJSON() as Prisma.InputJsonValue,
        deadline: params.deadline,
        fields: {
          create: params.fields.map((field) => ({
            key: field.key,
            label: field.label.toJSON() as Prisma.InputJsonValue,
            type: FormMapper.toPrismaFieldType(field.type),
            required: field.required,
            options: field.options,
            position: field.position,
          })),
        },
      },
      include: { fields: true },
    });
    return FormMapper.toDomain(row);
  }

  async delete(id: string): Promise<void> {
    await this.prisma.form.delete({ where: { id } });
  }

  async submit(params: SubmitFormParams): Promise<boolean> {
    try {
      // Envío y respuestas en la misma escritura: un envío sin respuestas o
      // unas respuestas huérfanas no significan nada.
      await this.prisma.formSubmission.create({
        data: {
          formId: params.formId,
          deviceId: params.deviceId.value,
          answers: {
            create: params.answers.map((answer) => ({
              fieldId: answer.fieldId,
              value: answer.value,
            })),
          },
        },
      });
      return true;
    } catch (error) {
      // P2002 = UNIQUE (form_id, device_id): este dispositivo ya envió.
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
