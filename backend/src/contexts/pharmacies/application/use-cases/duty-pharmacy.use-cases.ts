import { Inject, Injectable } from '@nestjs/common';
import { NotFoundError } from '../../../../shared/domain/errors/common-errors';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { DutyPharmacy } from '../../domain/entities/duty-pharmacy.entity';
import { PharmacyForbiddenError } from '../../domain/errors/pharmacy-errors';
import {
  DUTY_PHARMACY_READER_PORT,
  DUTY_PHARMACY_WRITER_PORT,
} from '../../domain/ports/duty-pharmacy.port';
import type {
  DutyPharmacyReaderPort,
  DutyPharmacyWriterPort,
} from '../../domain/ports/duty-pharmacy.port';

// Normaliza a medianoche UTC: la columna es DATE, la hora no significa nada.
function toUtcDay(date: Date): Date {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
}

const DEFAULT_RANGE_DAYS = 14;
const MAX_RANGE_DAYS = 60;

export interface ListDutyPharmaciesInput {
  municipalityId: string;
  from?: Date;
  days?: number;
}

@Injectable()
export class ListDutyPharmaciesUseCase {
  constructor(
    @Inject(DUTY_PHARMACY_READER_PORT)
    private readonly reader: DutyPharmacyReaderPort,
  ) {}

  async execute(
    input: ListDutyPharmaciesInput,
  ): Promise<Result<DutyPharmacy[]>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const from = toUtcDay(input.from ?? new Date());
    const days =
      input.days && input.days > 0 && input.days <= MAX_RANGE_DAYS
        ? input.days
        : DEFAULT_RANGE_DAYS;
    const to = new Date(from.getTime() + days * 86_400_000);

    const pharmacies = await this.reader.findInRange({
      municipalityId,
      from,
      to,
    });
    return Result.success(pharmacies);
  }
}

// Consulta más frecuente de la pantalla: "quién está de guardia hoy".
@Injectable()
export class GetTodayDutyPharmacyUseCase {
  constructor(
    @Inject(DUTY_PHARMACY_READER_PORT)
    private readonly reader: DutyPharmacyReaderPort,
  ) {}

  async execute(
    rawMunicipalityId: string,
    date?: Date,
  ): Promise<Result<DutyPharmacy>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(rawMunicipalityId);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const day = toUtcDay(date ?? new Date());
    const pharmacy = await this.reader.findByDate(municipalityId, day);
    if (!pharmacy) {
      // Que no haya guardia cargada es información útil: la app muestra un
      // mensaje explícito en vez de una pantalla vacía.
      return Result.failure(
        new NotFoundError(
          `No duty pharmacy registered for ${day.toISOString().slice(0, 10)}`,
        ),
      );
    }
    return Result.success(pharmacy);
  }
}

export interface UpsertDutyPharmacyInput {
  managerId: string;
  municipalityId: string;
  date: Date;
  pharmacyName: string;
  address: string;
  phone: string;
  schedule: string;
}

@Injectable()
export class UpsertDutyPharmacyUseCase {
  constructor(
    @Inject(DUTY_PHARMACY_WRITER_PORT)
    private readonly writer: DutyPharmacyWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
  ) {}

  async execute(input: UpsertDutyPharmacyInput): Promise<Result<DutyPharmacy>> {
    let municipalityId: MunicipalityId;
    try {
      municipalityId = MunicipalityId.create(input.municipalityId);

      // Invariantes de la entidad (ningún campo vacío) antes de escribir.
      DutyPharmacy.create({
        id: 'pending',
        municipalityId,
        date: toUtcDay(input.date),
        pharmacyName: input.pharmacyName,
        address: input.address,
        phone: input.phone,
        schedule: input.schedule,
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
        new PharmacyForbiddenError(input.managerId, municipalityId.value),
      );
    }

    const pharmacy = await this.writer.upsert({
      municipalityId,
      date: toUtcDay(input.date),
      pharmacyName: input.pharmacyName,
      address: input.address,
      phone: input.phone,
      schedule: input.schedule,
    });
    return Result.success(pharmacy);
  }
}
