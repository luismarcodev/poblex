import { ValidationError } from '../../../../shared/domain/errors/common-errors';

export type SourceKind = 'aemet' | 'manual';

const SOURCES: readonly SourceKind[] = ['aemet', 'manual'];

export class AlertSource {
  private constructor(readonly value: SourceKind) {}

  static create(value: string): AlertSource {
    const normalized = value.trim().toLowerCase();
    if (!SOURCES.includes(normalized as SourceKind)) {
      throw new ValidationError(
        `Invalid AlertSource: "${value}" (expected aemet or manual)`,
      );
    }
    return new AlertSource(normalized as SourceKind);
  }

  static aemet(): AlertSource {
    return new AlertSource('aemet');
  }

  static manual(): AlertSource {
    return new AlertSource('manual');
  }

  get isAemet(): boolean {
    return this.value === 'aemet';
  }

  get isManual(): boolean {
    return this.value === 'manual';
  }
}
