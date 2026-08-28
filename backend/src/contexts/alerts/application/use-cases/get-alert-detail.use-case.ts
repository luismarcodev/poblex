import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Alert } from '../../domain/entities/alert.entity';
import { AlertNotFoundError } from '../../domain/errors/alert-errors';
import { ALERT_READER_PORT } from '../../domain/ports/alert-reader.port';
import type { AlertReaderPort } from '../../domain/ports/alert-reader.port';

@Injectable()
export class GetAlertDetailUseCase {
  constructor(
    @Inject(ALERT_READER_PORT) private readonly reader: AlertReaderPort,
  ) {}

  async execute(id: string, rawMunicipalityId: string): Promise<Result<Alert>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const alert = await this.reader.findByIdForMunicipality(id, municipalityId);
    if (!alert) {
      return Result.failure(new AlertNotFoundError(id));
    }
    return Result.success(alert);
  }
}
