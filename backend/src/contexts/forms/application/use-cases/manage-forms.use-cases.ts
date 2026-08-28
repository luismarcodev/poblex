import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { toCsv } from '../../../../shared/infrastructure/http/csv';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Form, FormField } from '../../domain/entities/form.entity';
import {
  FormForbiddenError,
  FormNotFoundError,
} from '../../domain/errors/form-errors';
import { FORM_READER_PORT } from '../../domain/ports/form-reader.port';
import type { FormReaderPort } from '../../domain/ports/form-reader.port';
import { FORM_WRITER_PORT } from '../../domain/ports/form-writer.port';
import type {
  CreateFormFieldParams,
  FormWriterPort,
} from '../../domain/ports/form-writer.port';
import { FormFieldType } from '../../domain/value-objects/form-field-type.vo';

export interface CreateFormFieldInput {
  key: string;
  label: { es?: string; va?: string };
  type: string;
  required?: boolean;
  options?: string[];
}

export interface CreateFormInput {
  managerId: string;
  municipalityId: string;
  title: { es?: string; va?: string };
  description: { es?: string; va?: string };
  deadline?: Date;
  fields: CreateFormFieldInput[];
}

@Injectable()
export class CreateFormUseCase {
  constructor(
    @Inject(FORM_WRITER_PORT) private readonly writer: FormWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: CreateFormInput): Promise<Result<Form>> {
    let municipalityId: MunicipalityId;
    let title: LocalizedText;
    let description: LocalizedText;
    let fields: CreateFormFieldParams[];
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      title = LocalizedText.create(input.title);
      description = LocalizedText.create(input.description);
      fields = input.fields.map((field, index) => ({
        key: field.key,
        label: LocalizedText.create(field.label),
        type: FormFieldType.create(field.type),
        required: field.required ?? false,
        options: field.options ?? [],
        position: index,
      }));

      // Invariantes de la entidad (claves únicas, select con opciones) antes
      // de escribir nada.
      Form.create({
        id: 'pending',
        municipalityId,
        title,
        description,
        deadline: input.deadline ?? null,
        fields: fields.map((field, index) =>
          FormField.create({ ...field, id: `pending-${index}` }),
        ),
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      input.managerId,
      municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new FormForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const form = await this.writer.create({
      municipalityId,
      title,
      description,
      deadline: input.deadline ?? null,
      fields,
    });
    return Result.success(form);
  }
}

@Injectable()
export class AuthorizeFormMutationService {
  constructor(
    @Inject(FORM_READER_PORT) private readonly reader: FormReaderPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async ensureMutable(
    formId: string,
    managerId: string,
  ): Promise<Result<Form>> {
    const existing = await this.reader.findById(formId);
    if (!existing) {
      return Result.failure(new FormNotFoundError(formId));
    }

    const isAuthorized = await this.managers.isManagerOfMunicipality(
      managerId,
      existing.municipalityId.value,
    );
    if (!isAuthorized) {
      return Result.failure(
        new FormForbiddenError(managerId, existing.municipalityId.value),
      );
    }

    return Result.success(existing);
  }
}

@Injectable()
export class DeleteFormUseCase {
  constructor(
    @Inject(FORM_WRITER_PORT) private readonly writer: FormWriterPort,
    private readonly authorize: AuthorizeFormMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<void>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    await this.writer.delete(id);
    return Result.success(undefined);
  }
}

// Exportación prometida en el PRD: el gestor saca el censo a una hoja de
// cálculo. Una columna por campo, en el orden del formulario. NO se exporta
// el device_id: identificaría de forma estable a quién respondió qué.
@Injectable()
export class ExportFormSubmissionsUseCase {
  constructor(
    @Inject(FORM_READER_PORT) private readonly reader: FormReaderPort,
    private readonly authorize: AuthorizeFormMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<string>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);
    const form = authorized.value;

    const submissions = await this.reader.findSubmissionsForExport(id);
    const headers = ['enviado_en', ...form.fields.map((field) => field.key)];
    const rows = submissions.map((submission) => [
      submission.submittedAt.toISOString(),
      ...form.fields.map(
        (field) => submission.valuesByFieldId.get(field.id) ?? '',
      ),
    ]);

    return Result.success(toCsv(headers, rows));
  }
}
