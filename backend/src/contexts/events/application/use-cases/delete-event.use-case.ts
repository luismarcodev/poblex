import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { EVENT_WRITER_PORT } from '../../domain/ports/event-writer.port';
import type { EventWriterPort } from '../../domain/ports/event-writer.port';
import { AuthorizeEventMutationService } from '../services/authorize-event-mutation.service';

@Injectable()
export class DeleteEventUseCase {
  constructor(
    @Inject(EVENT_WRITER_PORT) private readonly writer: EventWriterPort,
    private readonly authorize: AuthorizeEventMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<void>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    // Los recordatorios asociados caen por ON DELETE CASCADE: nadie recibe un
    // aviso de un evento que ya no existe.
    await this.writer.delete(id);
    return Result.success(undefined);
  }
}
