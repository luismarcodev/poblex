import { UnparsableInboundPostError } from '../../domain/errors/social-errors';
import type { InboundSocialPost } from '../../domain/ports/social-listener.port';

// Comprobación de integridad de datos, no editorial: un post sin texto ni
// imagen no da para una News mínimamente útil. No juzga el CONTENIDO del
// post (eso quedó descartado a propósito — publicación automática pura).
export function assertParseablePost(post: InboundSocialPost): void {
  const hasText = (post.caption ?? '').trim().length > 0;
  const hasImage = (post.imageUrl ?? '').trim().length > 0;
  if (!hasText && !hasImage) {
    throw new UnparsableInboundPostError(post.externalId);
  }
}
