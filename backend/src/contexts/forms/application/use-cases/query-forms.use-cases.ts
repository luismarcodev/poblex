import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Form } from '../../domain/entities/form.entity';
import { FormNotFoundError } from '../../domain/errors/form-errors';
import { FORM_READER_PORT } from '../../domain/ports/form-reader.port';
import type {
  FormListResult,
  FormReaderPort,
} from '../../domain/ports/form-reader.port';

export interface ListFormsInput {
  municipalityId: string;
  includeClosed?: boolean;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListFormsUseCase {
  constructor(
    @Inject(FORM_READER_PORT) private readonly reader: FormReaderPort,
  ) {}

  async execute(input: ListFormsInput): Promise<Result<FormListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const result = await this.reader.find({
      municipalityId,
      openAt: input.includeClosed ? undefined : new Date(),
      cursor: input.cursor,
      limit:
        input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
          ? input.limit
          : DEFAULT_LIMIT,
    });
    return Result.success(result);
  }
}

export interface FormDetail {
  form: Form;
  alreadySubmitted: boolean;
}

@Injectable()
export class GetFormDetailUseCase {
  constructor(
    @Inject(FORM_READER_PORT) private readonly reader: FormReaderPort,
  ) {}

  async execute(
    id: string,
    rawMunicipalityId: string,
    rawDeviceId: string | undefined,
  ): Promise<Result<FormDetail>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const form = await this.reader.findByIdForMunicipality(id, municipalityId);
    if (!form) {
      return Result.failure(new FormNotFoundError(id));
    }

    // Leer un formulario no es escribir: un X-Device-Id ausente o mal formado
    // no bloquea la consulta, solo impide saber si ya se envió.
    let alreadySubmitted = false;
    if (rawDeviceId) {
      try {
        alreadySubmitted = await this.reader.hasSubmitted(
          id,
          DeviceId.create(rawDeviceId),
        );
      } catch {
        alreadySubmitted = false;
      }
    }

    return Result.success({ form, alreadySubmitted });
  }
}
