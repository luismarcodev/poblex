import { randomUUID } from 'node:crypto';
import { Injectable } from '@nestjs/common';
import type {
  FacebookPublishResult,
  InstagramContainerStatus,
  SocialPublisherPort,
} from '../../../domain/ports/social-publisher.port';

// Adaptador de desarrollo — publica "en el vacío" y devuelve identificadores
// falsos deterministas. El contenedor de Instagram se da por FINISHED
// inmediatamente: la máquina de estados en sí (pending→container_created→
// processing→published) ya está cubierta por tests unitarios con fakes
// totalmente controlados, no por este adaptador de desarrollo.
@Injectable()
export class FakeMetaPublisherAdapter implements SocialPublisherPort {
  publishToFacebook(): Promise<FacebookPublishResult> {
    return Promise.resolve({ externalPostId: `fake-fb-post-${randomUUID()}` });
  }

  createInstagramContainer(): Promise<{ containerId: string }> {
    return Promise.resolve({
      containerId: `fake-ig-container-${randomUUID()}`,
    });
  }

  getInstagramContainerStatus(): Promise<InstagramContainerStatus> {
    return Promise.resolve('finished');
  }

  publishInstagramContainer(): Promise<{ externalPostId: string }> {
    return Promise.resolve({ externalPostId: `fake-ig-post-${randomUUID()}` });
  }
}
