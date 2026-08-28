import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type PlatformKind = 'instagram' | 'facebook';

const PLATFORMS: readonly PlatformKind[] = ['instagram', 'facebook'];

export class SocialPlatform {
  private constructor(readonly value: PlatformKind) {}

  static create(value: string): SocialPlatform {
    const normalized = value.trim().toLowerCase();
    if (!PLATFORMS.includes(normalized as PlatformKind)) {
      throw new ValidationError(
        `Invalid SocialPlatform: "${value}" (expected instagram or facebook)`,
      );
    }
    return new SocialPlatform(normalized as PlatformKind);
  }

  static instagram(): SocialPlatform {
    return new SocialPlatform('instagram');
  }

  static facebook(): SocialPlatform {
    return new SocialPlatform('facebook');
  }

  get isInstagram(): boolean {
    return this.value === 'instagram';
  }

  get isFacebook(): boolean {
    return this.value === 'facebook';
  }

  equals(other: SocialPlatform): boolean {
    return this.value === other.value;
  }
}
