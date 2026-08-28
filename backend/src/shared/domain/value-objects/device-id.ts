import { ValidationError } from '../errors/common-errors';

const UUID_V4_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

// X-Device-Id: UUID v4 generado por el cliente. Falsificable por diseño —
// no autoriza nada sensible, ver CLAUDE.md "Autenticación".
export class DeviceId {
  private constructor(readonly value: string) {}

  static create(value: string): DeviceId {
    if (!value || !UUID_V4_REGEX.test(value)) {
      throw new ValidationError(`Invalid DeviceId: "${value}"`);
    }
    return new DeviceId(value);
  }

  equals(other: DeviceId): boolean {
    return this.value === other.value;
  }
}
