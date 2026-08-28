import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { Reservation, ReservationProps } from './reservation.entity';

const SOLLANA_ID = 'a1b2c3d4-e5f6-4789-a012-3456789abcde';
const DEVICE_ID = 'd1b2c3d4-e5f6-4789-a012-3456789abcde';

function baseProps(overrides: Partial<ReservationProps> = {}): ReservationProps {
  return {
    id: 'r1b2c3d4-e5f6-4789-a012-3456789abcde',
    facilityId: 'f1b2c3d4-e5f6-4789-a012-3456789abcde',
    municipalityId: MunicipalityId.create(SOLLANA_ID),
    deviceId: DEVICE_ID,
    slotStart: new Date('2026-08-20T09:00:00Z'),
    slotEnd: new Date('2026-08-20T10:00:00Z'),
    createdAt: new Date('2026-08-13T10:00:00Z'),
    ...overrides,
  };
}

describe('Reservation', () => {
  it('creates a valid reservation', () => {
    const reservation = Reservation.create(baseProps());
    expect(reservation.deviceId).toBe(DEVICE_ID);
  });

  it('rejects slotEnd equal to slotStart', () => {
    expect(() =>
      Reservation.create(
        baseProps({
          slotStart: new Date('2026-08-20T09:00:00Z'),
          slotEnd: new Date('2026-08-20T09:00:00Z'),
        }),
      ),
    ).toThrow(ValidationError);
  });

  it('rejects slotEnd before slotStart', () => {
    expect(() =>
      Reservation.create(
        baseProps({
          slotStart: new Date('2026-08-20T09:00:00Z'),
          slotEnd: new Date('2026-08-20T08:00:00Z'),
        }),
      ),
    ).toThrow(ValidationError);
  });

  describe('isOwnedBy', () => {
    it('returns true for the owning device', () => {
      const reservation = Reservation.create(baseProps());
      expect(reservation.isOwnedBy(DEVICE_ID)).toBe(true);
    });

    it('returns false for a different device', () => {
      const reservation = Reservation.create(baseProps());
      expect(reservation.isOwnedBy('other-device')).toBe(false);
    });
  });
});
