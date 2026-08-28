import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { SubmissionAnswer } from '../../domain/entities/form.entity';
import {
  AlreadySubmittedError,
  FormClosedError,
  FormNotFoundError,
  InvalidSubmissionError,
} from '../../domain/errors/form-errors';
import { FORM_READER_PORT } from '../../domain/ports/form-reader.port';
import type { FormReaderPort } from '../../domain/ports/form-reader.port';
import { FORM_WRITER_PORT } from '../../domain/ports/form-writer.port';
import type { FormWriterPort } from '../../domain/ports/form-writer.port';

export interface SubmitFormInput {
  formId: string;
  deviceId: string | undefined;
  answers: SubmissionAnswer[];
}

@Injectable()
export class SubmitFormUseCase {
  constructor(
    @Inject(FORM_READER_PORT) private readonly reader: FormReaderPort,
    @Inject(FORM_WRITER_PORT) private readonly writer: FormWriterPort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(input: SubmitFormInput): Promise<Result<void>> {
    const device = await this.requireDevice.ensure(input.deviceId);
    if (device.isFailure) return Result.failure(device.error);

    const form = await this.reader.findById(input.formId);
    if (!form || !form.municipalityId.equals(device.value.municipalityId)) {
      return Result.failure(new FormNotFoundError(input.formId));
    }

    if (!form.isOpenAt(new Date())) {
      return Result.failure(new FormClosedError(input.formId));
    }

    // Toda la validación de campos vive en la entidad: obligatorios, tipos y
    // opciones permitidas.
    const problems = form.validateSubmission(input.answers);
    if (problems.length > 0) {
      return Result.failure(new InvalidSubmissionError(problems));
    }

    const accepted = await this.writer.submit({
      formId: input.formId,
      deviceId: device.value.id,
      answers: input.answers,
    });
    if (!accepted) {
      return Result.failure(new AlreadySubmittedError(input.formId));
    }

    return Result.success(undefined);
  }
}
