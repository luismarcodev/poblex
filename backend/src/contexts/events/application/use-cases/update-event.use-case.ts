import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalEvent } from '../../domain/entities/event.entity';
import { EVENT_WRITER_PORT } from '../../domain/ports/event-writer.port';
import type {
  EventWriterPort,
  UpdateEventFields,
} from '../../domain/ports/event-writer.port';
import { EventCategory } from '../../domain/value-objects/event-category.vo';
import { AuthorizeEventMutationService } from '../services/authorize-event-mutation.service';

export interface UpdateEventInput {
  id: string;
  managerId: string;
  title?: { es?: string; va?: string };
  description?: { es?: string; va?: string };
  startAt?: Date;
  endAt?: Date | null;
  locationName?: string | null;
  lat?: number | null;
  lng?: number | null;
  category?: string;
}

@Injectable()
export class UpdateEventUseCase {
  constructor(
    @Inject(EVENT_WRITER_PORT) private readonly writer: EventWriterPort,
    private readonly authorize: AuthorizeEventMutationService,
  ) {}

  async execute(input: UpdateEventInput): Promise<Result<MunicipalEvent>> {
    const authorized = await this.authorize.ensureMutable(
      input.id,
      input.managerId,
    );
    if (authorized.isFailure) return Result.failure(authorized.error);
    const existing = authorized.value;

    let fields: UpdateEventFields;
    try {
      fields = {
        title: input.title ? LocalizedText.create(input.title) : undefined,
        description: input.description
          ? LocalizedText.create(input.description)
          : undefined,
        startAt: input.startAt,
        endAt: input.endAt,
        locationName: input.locationName,
        lat: input.lat,
        lng: input.lng,
        category: input.category
          ? EventCategory.create(input.category)
          : undefined,
      };

      // Las invariantes se comprueban sobre el resultado de FUSIONAR lo
      // existente con el parche: un `endAt` nuevo puede quedar antes de un
      // `startAt` que no se está tocando.
      MunicipalEvent.create({
        id: existing.id,
        municipalityId: existing.municipalityId,
        title: fields.title ?? existing.title,
        description: fields.description ?? existing.description,
        startAt: fields.startAt ?? existing.startAt,
        endAt: input.endAt === undefined ? existing.endAt : input.endAt,
        locationName:
          input.locationName === undefined
            ? existing.locationName
            : input.locationName,
        lat: input.lat === undefined ? existing.lat : input.lat,
        lng: input.lng === undefined ? existing.lng : input.lng,
        category: fields.category ?? existing.category,
      });
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const updated = await this.writer.update(input.id, fields);
    return Result.success(updated);
  }
}
