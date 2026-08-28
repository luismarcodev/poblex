import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { Alert } from '../../domain/entities/alert.entity';
import { ALERT_WRITER_PORT } from '../../domain/ports/alert-writer.port';
import type {
  AlertWriterPort,
  UpdateAlertFields,
} from '../../domain/ports/alert-writer.port';
import { AlertPhenomenonType } from '../../domain/value-objects/alert-phenomenon-type.vo';
import { AlertSeverity } from '../../domain/value-objects/alert-severity.vo';
import { AuthorizeAlertMutationService } from '../services/authorize-alert-mutation.service';

export interface UpdateManualAlertInput {
  id: string;
  managerId: string;
  severity?: string;
  phenomenonType?: string;
  phenomenon?: string;
  body?: { es?: string; va?: string };
  startAt?: Date;
  endAt?: Date | null;
}

@Injectable()
export class UpdateManualAlertUseCase {
  constructor(
    @Inject(ALERT_WRITER_PORT) private readonly writer: AlertWriterPort,
    private readonly authorize: AuthorizeAlertMutationService,
  ) {}

  async execute(input: UpdateManualAlertInput): Promise<Result<Alert>> {
    const authorized = await this.authorize.ensureMutable(
      input.id,
      input.managerId,
    );
    if (authorized.isFailure) return Result.failure(authorized.error);
    const existing = authorized.value;

    let fields: UpdateAlertFields;
    try {
      fields = {
        severity: input.severity
          ? AlertSeverity.create(input.severity)
          : undefined,
        phenomenonType: input.phenomenonType
          ? AlertPhenomenonType.create(input.phenomenonType)
          : undefined,
        phenomenon: input.phenomenon,
        body: input.body ? LocalizedText.create(input.body) : undefined,
        startAt: input.startAt,
        endAt: input.endAt,
        // Auditoría: quién tocó la alerta por última vez.
        updatedBy: input.managerId,
      };

      Alert.create({
        id: existing.id,
        municipalityId: existing.municipalityId,
        source: existing.source,
        severity: fields.severity ?? existing.severity,
        phenomenonType: fields.phenomenonType ?? existing.phenomenonType,
        phenomenon: fields.phenomenon ?? existing.phenomenon,
        body: fields.body ?? existing.body,
        startAt: fields.startAt ?? existing.startAt,
        endAt: input.endAt === undefined ? existing.endAt : input.endAt,
        aemetId: existing.aemetId,
        createdBy: existing.createdBy,
        updatedBy: input.managerId,
        createdAt: existing.createdAt,
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const updated = await this.writer.update(input.id, fields);
    return Result.success(updated);
  }
}
