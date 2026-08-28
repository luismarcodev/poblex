import { randomUUID } from 'node:crypto';
import { Inject, Injectable } from '@nestjs/common';
import { DomainError } from '../../../../shared/domain/errors/domain-error';
import { Result } from '../../../../shared/domain/result';
import { FILE_STORAGE_PORT } from '../../../../shared/infrastructure/storage/file-storage.port';
import type { FileStoragePort } from '../../../../shared/infrastructure/storage/file-storage.port';
import { assertValidImage } from '../../../../shared/infrastructure/storage/image-validation';
import { RequireRegisteredDeviceService } from '../../../devices/application/services/require-registered-device.service';
import { Incident } from '../../domain/entities/incident.entity';
import {
  IncidentNotFoundError,
  IncidentNotOwnedError,
} from '../../domain/errors/incident-errors';
import { INCIDENT_READER_PORT } from '../../domain/ports/incident-reader.port';
import type { IncidentReaderPort } from '../../domain/ports/incident-reader.port';
import { INCIDENT_WRITER_PORT } from '../../domain/ports/incident-writer.port';
import type { IncidentWriterPort } from '../../domain/ports/incident-writer.port';

const EXTENSIONS: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

export interface UploadIncidentPhotoInput {
  incidentId: string;
  deviceId: string | undefined;
  bytes: Buffer;
}

// La foto de incidencia sube A TRAVÉS del backend, no con URL prefirmada como
// los adjuntos de noticias. Motivo: la sube un vecino NO autenticado, así que
// el único sitio donde se puede comprobar que el fichero es realmente una
// imagen es el servidor. Con una URL prefirmada el bucket aceptaría cualquier
// cosa con el Content-Type que dijera el cliente.
@Injectable()
export class UploadIncidentPhotoUseCase {
  constructor(
    @Inject(INCIDENT_READER_PORT) private readonly reader: IncidentReaderPort,
    @Inject(INCIDENT_WRITER_PORT) private readonly writer: IncidentWriterPort,
    @Inject(FILE_STORAGE_PORT) private readonly storage: FileStoragePort,
    private readonly requireDevice: RequireRegisteredDeviceService,
  ) {}

  async execute(input: UploadIncidentPhotoInput): Promise<Result<Incident>> {
    const device = await this.requireDevice.ensure(input.deviceId);
    if (device.isFailure) return Result.failure(device.error);

    const incident = await this.reader.findById(input.incidentId);
    if (!incident) {
      return Result.failure(new IncidentNotFoundError(input.incidentId));
    }
    if (!incident.belongsToDevice(device.value.id)) {
      return Result.failure(new IncidentNotOwnedError(input.incidentId));
    }

    let contentType: string;
    try {
      contentType = assertValidImage(input.bytes);
    } catch (error) {
      return Result.failure(error as DomainError);
    }

    const key = `incidents/${incident.municipalityId.value}/${incident.id}/${randomUUID()}.${EXTENSIONS[contentType]}`;
    const stored = await this.storage.putObject({
      key,
      contentType,
      body: input.bytes,
    });

    const updated = await this.writer.attachPhoto(
      incident.id,
      stored.publicUrl,
    );
    return Result.success(updated);
  }
}
