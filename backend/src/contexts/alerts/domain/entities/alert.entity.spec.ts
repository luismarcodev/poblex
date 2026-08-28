import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { AlertPhenomenonType } from '../value-objects/alert-phenomenon-type.vo';
import { AlertSeverity } from '../value-objects/alert-severity.vo';
import { AlertSource } from '../value-objects/alert-source.vo';
import { Alert, AlertProps } from './alert.entity';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';
const MANAGER_ID = '9a8b7c6d-5e4f-4a3b-9c8d-7e6f5a4b3c2d';

function buildProps(overrides: Partial<AlertProps> = {}): AlertProps {
  return {
    id: 'alert-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    source: AlertSource.manual(),
    severity: AlertSeverity.create('naranja'),
    phenomenonType: AlertPhenomenonType.meteorologico(),
    phenomenon: 'Lluvias',
    body: LocalizedText.create({ es: 'Precaución' }),
    startAt: new Date('2026-01-10T08:00:00Z'),
    endAt: new Date('2026-01-10T20:00:00Z'),
    aemetId: null,
    createdBy: MANAGER_ID,
    updatedBy: null,
    createdAt: new Date('2026-01-10T07:00:00Z'),
    ...overrides,
  };
}

describe('Alert', () => {
  it('rejects an alert that ends before it starts', () => {
    expect(() =>
      Alert.create(
        buildProps({
          startAt: new Date('2026-01-10T20:00:00Z'),
          endAt: new Date('2026-01-10T08:00:00Z'),
        }),
      ),
    ).toThrow(ValidationError);
  });

  // Auditoría no negociable: un sistema que notifica una emergencia a todo un
  // municipio necesita saber siempre quién publicó qué.
  it('rejects a manual alert without an author', () => {
    expect(() => Alert.create(buildProps({ createdBy: null }))).toThrow(
      ValidationError,
    );
  });

  // Sin aemetId no hay deduplicación posible entre sincronizaciones.
  it('rejects an AEMET alert without its external id', () => {
    expect(() =>
      Alert.create(
        buildProps({
          source: AlertSource.aemet(),
          createdBy: null,
          aemetId: null,
        }),
      ),
    ).toThrow(ValidationError);
  });

  it('accepts an AEMET alert with no author but with its external id', () => {
    const alert = Alert.create(
      buildProps({
        source: AlertSource.aemet(),
        createdBy: null,
        aemetId: 'AEMET-2026-0042',
      }),
    );

    expect(alert.createdBy).toBeNull();
    expect(alert.aemetId).toBe('AEMET-2026-0042');
  });

  describe('isActiveAt', () => {
    it('is not active before it starts', () => {
      const alert = Alert.create(buildProps());

      expect(alert.isActiveAt(new Date('2026-01-10T07:59:00Z'))).toBe(false);
    });

    it('is active between start and end', () => {
      const alert = Alert.create(buildProps());

      expect(alert.isActiveAt(new Date('2026-01-10T12:00:00Z'))).toBe(true);
    });

    it('is no longer active once it has ended', () => {
      const alert = Alert.create(buildProps());

      expect(alert.isActiveAt(new Date('2026-01-10T20:01:00Z'))).toBe(false);
    });

    // Sin fecha de fin se considera vigente hasta que alguien la cierre.
    it('stays active indefinitely when it has no end date', () => {
      const alert = Alert.create(buildProps({ endAt: null }));

      expect(alert.isActiveAt(new Date('2030-01-01T00:00:00Z'))).toBe(true);
    });
  });
});
