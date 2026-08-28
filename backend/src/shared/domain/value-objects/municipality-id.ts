import { ValidationError } from '../errors/common-errors';

const UUID_V4_REGEX =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export class MunicipalityId {
  private constructor(readonly value: string) {}

  static create(value: string): MunicipalityId {
    if (!value || !UUID_V4_REGEX.test(value)) {
      throw new ValidationError(`Invalid MunicipalityId: "${value}"`);
    }
    return new MunicipalityId(value);
  }

  equals(other: MunicipalityId): boolean {
    return this.value === other.value;
  }
}
