import { SocialPublicationStatus } from './social-publication-status.vo';

describe('SocialPublicationStatus', () => {
  it('allows the full Instagram chain: pending -> container_created -> processing -> published', () => {
    const pending = SocialPublicationStatus.pending();
    const containerCreated = SocialPublicationStatus.containerCreated();
    const processing = SocialPublicationStatus.processing();
    const published = SocialPublicationStatus.published();

    expect(pending.canTransitionTo(containerCreated)).toBe(true);
    expect(containerCreated.canTransitionTo(processing)).toBe(true);
    expect(processing.canTransitionTo(published)).toBe(true);
  });

  it('allows Facebook to skip straight from pending to published, no intermediate steps', () => {
    const pending = SocialPublicationStatus.pending();
    const published = SocialPublicationStatus.published();

    expect(pending.canTransitionTo(published)).toBe(true);
  });

  it('allows failure from any non-terminal state', () => {
    const failed = SocialPublicationStatus.failed();

    expect(SocialPublicationStatus.pending().canTransitionTo(failed)).toBe(
      true,
    );
    expect(
      SocialPublicationStatus.containerCreated().canTransitionTo(failed),
    ).toBe(true);
    expect(SocialPublicationStatus.processing().canTransitionTo(failed)).toBe(
      true,
    );
  });

  it('rejects skipping backwards or re-entering a terminal state', () => {
    expect(
      SocialPublicationStatus.processing().canTransitionTo(
        SocialPublicationStatus.pending(),
      ),
    ).toBe(false);
    expect(
      SocialPublicationStatus.published().canTransitionTo(
        SocialPublicationStatus.processing(),
      ),
    ).toBe(false);
    expect(
      SocialPublicationStatus.failed().canTransitionTo(
        SocialPublicationStatus.pending(),
      ),
    ).toBe(false);
  });

  it('rejects jumping straight from pending to processing, skipping container creation', () => {
    // Instagram siempre necesita el contenedor confirmado antes de sondear
    // "processing" — no es un atajo válido aunque parezca inofensivo.
    expect(
      SocialPublicationStatus.pending().canTransitionTo(
        SocialPublicationStatus.processing(),
      ),
    ).toBe(false);
  });

  it('marks published and failed as terminal', () => {
    expect(SocialPublicationStatus.published().isTerminal).toBe(true);
    expect(SocialPublicationStatus.failed().isTerminal).toBe(true);
    expect(SocialPublicationStatus.pending().isTerminal).toBe(false);
    expect(SocialPublicationStatus.processing().isTerminal).toBe(false);
  });

  it('rejects an unknown status string', () => {
    expect(() => SocialPublicationStatus.create('bogus')).toThrow();
  });
});
