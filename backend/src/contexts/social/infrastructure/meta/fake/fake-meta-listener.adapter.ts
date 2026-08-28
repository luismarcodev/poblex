import { Injectable } from '@nestjs/common';
import type {
  InboundSocialPost,
  SocialListenerPort,
} from '../../../domain/ports/social-listener.port';

// Adaptador de desarrollo: nunca inventa posts. Devolver una lista vacía es
// el comportamiento seguro por defecto — lo contrario inundaría el listado
// de noticias de contenido falso en cualquier entorno donde META_APP_ID no
// esté configurado (todo desarrollo local, hasta que la app de Meta esté
// aprobada).
@Injectable()
export class FakeMetaListenerAdapter implements SocialListenerPort {
  fetchRecentPosts(): Promise<InboundSocialPost[]> {
    return Promise.resolve([]);
  }
}
