import { Inject, Injectable } from '@nestjs/common';
import { Result } from '../../../../shared/domain/result';
import { ALERT_WRITER_PORT } from '../../domain/ports/alert-writer.port';
import type { AlertWriterPort } from '../../domain/ports/alert-writer.port';
import { AuthorizeAlertMutationService } from '../services/authorize-alert-mutation.service';

@Injectable()
export class DeleteManualAlertUseCase {
  constructor(
    @Inject(ALERT_WRITER_PORT) private readonly writer: AlertWriterPort,
    private readonly authorize: AuthorizeAlertMutationService,
  ) {}

  async execute(id: string, managerId: string): Promise<Result<void>> {
    const authorized = await this.authorize.ensureMutable(id, managerId);
    if (authorized.isFailure) return Result.failure(authorized.error);

    await this.writer.delete(id);
    return Result.success(undefined);
  }
}
