import { ConfigService } from '@nestjs/config';
import { SocialOAuthStateService } from './social-oauth-state.service';

function buildService(
  secret: string | null = 'test-app-secret',
): SocialOAuthStateService {
  const config = { get: () => secret } as unknown as ConfigService;
  return new SocialOAuthStateService(config);
}

describe('SocialOAuthStateService', () => {
  it('round-trips a signed state', () => {
    const service = buildService();
    const state = service.sign({
      managerId: 'manager-1',
      municipalityId: 'municipality-1',
      platform: 'instagram',
    });

    const payload = service.verify(state);

    expect(payload).toMatchObject({
      managerId: 'manager-1',
      municipalityId: 'municipality-1',
      platform: 'instagram',
    });
  });

  it('rejects a tampered state', () => {
    const service = buildService();
    const state = service.sign({
      managerId: 'manager-1',
      municipalityId: 'municipality-1',
      platform: 'instagram',
    });
    const [encoded] = state.split('.');
    const tampered = `${encoded}.invalid-signature-000000000000000000000000000`;

    expect(service.verify(tampered)).toBeNull();
  });

  it('rejects a state signed with a different secret', () => {
    const signer = buildService('secret-a');
    const verifier = buildService('secret-b');
    const state = signer.sign({
      managerId: 'manager-1',
      municipalityId: 'municipality-1',
      platform: 'instagram',
    });

    expect(verifier.verify(state)).toBeNull();
  });

  it('rejects an expired state', () => {
    const service = buildService();
    const state = service.sign({
      managerId: 'manager-1',
      municipalityId: 'municipality-1',
      platform: 'instagram',
    });

    const realNow = Date.now;
    Date.now = () => realNow() + 11 * 60 * 1000;
    try {
      expect(service.verify(state)).toBeNull();
    } finally {
      Date.now = realNow;
    }
  });

  it('rejects a malformed state', () => {
    const service = buildService();
    expect(service.verify('not-a-valid-state')).toBeNull();
  });
});
