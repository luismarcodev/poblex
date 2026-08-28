import { Inject, Injectable, Logger } from '@nestjs/common';
import { FILE_STORAGE_PORT } from '../../../../shared/infrastructure/storage/file-storage.port';
import type { FileStoragePort } from '../../../../shared/infrastructure/storage/file-storage.port';
import { INCIDENT_WRITER_PORT } from '../../domain/ports/incident-writer.port';
import type { IncidentWriterPort } from '../../domain/ports/incident-writer.port';

const BATCH_LIMIT = 200;

// Requisito legal: borrar del almacenamiento las fotos cuyo plazo de
// retención venció y limpiar photo_url. No es una mejora.
@Injectable()
export class PurgeIncidentPhotosUseCase {
  private readonly logger = new Logger(PurgeIncidentPhotosUseCase.name);

  constructor(
    @Inject(INCIDENT_WRITER_PORT) private readonly writer: IncidentWriterPort,
    @Inject(FILE_STORAGE_PORT) private readonly storage: FileStoragePort,
  ) {}

  async execute(now: Date = new Date()): Promise<number> {
    const pending = await this.writer.findPhotosToPurge(now, BATCH_LIMIT);
    let purged = 0;

    for (const photo of pending) {
      try {
        await this.storage.deleteByPublicUrl(photo.photoUrl);
      } catch (error) {
        // Si el objeto ya no está en el almacenamiento, la referencia en base
        // de datos sigue sobrando: se limpia igualmente.
        this.logger.warn(
          `Could not delete photo for incident ${photo.incidentId}: ${String(error)}`,
        );
      }
      await this.writer.clearPhoto(photo.incidentId);
      purged += 1;
    }

    return purged;
  }
}
