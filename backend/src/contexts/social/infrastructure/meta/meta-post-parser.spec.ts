import { UnparsableInboundPostError } from '../../domain/errors/social-errors';
import type { InboundSocialPost } from '../../domain/ports/social-listener.port';
import { assertParseablePost } from './meta-post-parser';

function buildPost(
  overrides: Partial<InboundSocialPost> = {},
): InboundSocialPost {
  return {
    externalId: 'post-1',
    caption: null,
    imageUrl: null,
    permalink: 'https://facebook.com/post-1',
    publishedAt: new Date(),
    ...overrides,
  };
}

describe('assertParseablePost', () => {
  it('accepts a post with only caption text', () => {
    expect(() =>
      assertParseablePost(buildPost({ caption: 'Hola vecinos' })),
    ).not.toThrow();
  });

  it('accepts a post with only an image', () => {
    expect(() =>
      assertParseablePost(
        buildPost({ imageUrl: 'https://example.com/img.jpg' }),
      ),
    ).not.toThrow();
  });

  it('rejects a post with no text and no image', () => {
    expect(() => assertParseablePost(buildPost())).toThrow(
      UnparsableInboundPostError,
    );
  });

  it('rejects a post with blank caption and blank image url', () => {
    expect(() =>
      assertParseablePost(buildPost({ caption: '   ', imageUrl: '  ' })),
    ).toThrow(UnparsableInboundPostError);
  });
});
