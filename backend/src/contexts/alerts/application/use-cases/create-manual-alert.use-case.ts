import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { Alert } from '../../domain/entities/alert.entity';
import { AlertForbiddenError } from '../../domain/errors/alert-errors';
import { ALERT_WRITER_PORT } from '../../domain/ports/alert-writer.port';
import type { AlertWriterPort } from '../../domain/ports/alert-writer.port';
import { AlertPhenomenonType } from '../../domain/value-objects/alert-phenomenon-type.vo';
import { AlertSeverity } from '../../domain/value-objects/alert-severity.vo';
import { AlertSource } from '../../domain/value-objects/alert-source.vo';

export interface CreateManualAlertInput {
  managerId: string;
  municipalityId: string;
  severity: string;
  phenomenonType: string;
  phenomenon: string;
  body: { es?: string; va?: string };
  startAt: Date;
  endAt?: Date;
}

@Injectable()
export class CreateManualAlertUseCase {
  constructor(
    @Inject(ALERT_WRITER_PORT) private readonly writer: AlertWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly broadcast: BroadcastNotifier,
  ) {}

  async execute(input: CreateManualAlertInput): Promise<Result<Alert>> {
    let municipalityId: MunicipalityId;
    let severity: AlertSeverity;
    let phenomenonType: AlertPhenomenonType;
    let body: LocalizedText;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
      severity = AlertSeverity.create(input.severity);
      phenomenonType = AlertPhenomenonType.create(input.phenomenonType);
      body = LocalizedText.create(input.body);

      Alert.create({
        id: 'pending',
        municipalityId,
        source: AlertSource.manual(),
        severity,
        phenomenonType,
        phenomenon: input.phenomenon,
        body,
        startAt: input.startAt,
        endAt: input.endAt ?? null,
        aemetId: null,
        createdBy: input.managerId,
        updatedBy: null,
        createdAt: new Date(),
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
        new AlertForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const alert = await this.writer.create({
      municipalityId,
      source: AlertSource.manual(),
      severity,
      phenomenonType,
      phenomenon: input.phenomenon,
      body,
      startAt: input.startAt,
      endAt: input.endAt ?? null,
      aemetId: null,
      createdBy: input.managerId,
    });

    await this.broadcast.broadcast({
      municipalityId: municipalityId.value,
      channel: 'alerts',
      title: LocalizedText.create({
        es: `Aviso ${severity.value}: ${alert.phenomenon}`,
        va: `Avís ${severity.value}: ${alert.phenomenon}`,
      }),
      body,
      data: {
        type: 'alert',
        id: alert.id,
        severity: severity.value,
        // La app no puede silenciar una alerta roja: la marca viaja en la
        // carga para que el cliente no la filtre por preferencias locales.
        forced: String(severity.forcesNotification),
      },
    });

    return Result.success(alert);
  }
}
