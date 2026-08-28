import { Inject, Injectable } from '@nestjs/common';
import { NEWS_WRITER_PORT } from '../../domain/ports/news-writer.port';
import type { NewsWriterPort } from '../../domain/ports/news-writer.port';

const AUTO_ARCHIVE_AFTER_DAYS = 90;

// Invocada por la cron diaria (shared/infrastructure/cron), no por HTTP.
// Cero lógica de negocio en el fichero de cron: solo llama a este caso de uso.
@Injectable()
export class AutoArchiveNewsUseCase {
  constructor(
    @Inject(NEWS_WRITER_PORT) private readonly writer: NewsWriterPort,
  ) {}

  async execute(): Promise<number> {
    return this.writer.archiveOlderThan(AUTO_ARCHIVE_AFTER_DAYS);
  }
}
