import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { BroadcastNotifier } from '../../../../shared/infrastructure/notifications/broadcast-notifier.service';
import { MANAGER_REPOSITORY_PORT } from '../../../managers/domain/ports/manager-repository.port';
import type { ManagerRepositoryPort } from '../../../managers/domain/ports/manager-repository.port';
import { MunicipalEvent } from '../../domain/entities/event.entity';
import { EventForbiddenError } from '../../domain/errors/event-errors';
import { EVENT_WRITER_PORT } from '../../domain/ports/event-writer.port';
import type { EventWriterPort } from '../../domain/ports/event-writer.port';
import { EventCategory } from '../../domain/value-objects/event-category.vo';

export interface CreateEventInput {
  managerId: string;
  // Lista, no uno: un gestor con varios municipios publica el mismo acto en
  // todos de golpe (ej. una campaña comarcal).
  municipalityIds: string[];
  title: { es?: string; va?: string };
  description: { es?: string; va?: string };
  startAt: Date;
  endAt?: Date;
  locationName?: string;
  lat?: number;
  lng?: number;
  category: string;
}

@Injectable()
export class CreateEventUseCase {
  constructor(
    @Inject(EVENT_WRITER_PORT) private readonly writer: EventWriterPort,
    @Inject(MANAGER_REPOSITORY_PORT)
    private readonly managers: ManagerRepositoryPort,
    private readonly broadcast: BroadcastNotifier,
  ) {}

  async execute(input: CreateEventInput): Promise<Result<MunicipalEvent[]>> {
    let municipalityIds: MunicipalityId[];
    let title: LocalizedText;
    let description: LocalizedText;
    let category: EventCategory;
    try {
      municipalityIds = input.municipalityIds.map((id) =>
        MunicipalityId.create(id),
      );
      title = LocalizedText.create(input.title);
      description = LocalizedText.create(input.description);
      category = EventCategory.create(input.category);

      // Valida las invariantes de la entidad (fechas, coordenadas) ANTES de
      // tocar la base de datos.
      MunicipalEvent.create({
        id: 'pending',
        municipalityId: municipalityIds[0],
        title,
        description,
        startAt: input.startAt,
        endAt: input.endAt ?? null,
        locationName: input.locationName ?? null,
        lat: input.lat ?? null,
        lng: input.lng ?? null,
        category,
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    // Todos los municipios se autorizan antes de escribir ninguno.
    for (const municipalityId of municipalityIds) {
      const isAuthorized = await this.managers.isManagerOfMunicipality(
        input.managerId,
        municipalityId.value,
      );
      if (!isAuthorized) {
        return Result.failure(
          new EventForbiddenError(input.managerId, municipalityId.value),
        );
      }
    }

    const created: MunicipalEvent[] = [];
    for (const municipalityId of municipalityIds) {
      const event = await this.writer.create({
        municipalityId,
        title,
        description,
        startAt: input.startAt,
        endAt: input.endAt ?? null,
        locationName: input.locationName ?? null,
        lat: input.lat ?? null,
        lng: input.lng ?? null,
        category,
      });
      created.push(event);

      await this.broadcast.broadcast({
        municipalityId: municipalityId.value,
        channel: 'events',
        title,
        body: description,
        data: { type: 'event', id: event.id },
      });
    }

    return Result.success(created);
  }
}
