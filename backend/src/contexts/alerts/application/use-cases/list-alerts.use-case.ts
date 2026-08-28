import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { ALERT_READER_PORT } from '../../domain/ports/alert-reader.port';
import type {
  AlertListResult,
  AlertReaderPort,
} from '../../domain/ports/alert-reader.port';

export interface ListAlertsInput {
  municipalityId: string;
  // Por defecto solo las vigentes. El histórico se pide explícitamente.
  includeExpired?: boolean;
  cursor?: string;
  limit?: number;
}

const DEFAULT_LIMIT = 20;
const MAX_LIMIT = 50;

@Injectable()
export class ListAlertsUseCase {
  constructor(
    @Inject(ALERT_READER_PORT) private readonly reader: AlertReaderPort,
  ) {}

  async execute(input: ListAlertsInput): Promise<Result<AlertListResult>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const limit =
      input.limit && input.limit > 0 && input.limit <= MAX_LIMIT
        ? input.limit
        : DEFAULT_LIMIT;

    const result = await this.reader.find({
      municipalityId,
      activeAt: input.includeExpired ? undefined : new Date(),
      cursor: input.cursor,
      limit,
    });
    return Result.success(result);
  }
}
