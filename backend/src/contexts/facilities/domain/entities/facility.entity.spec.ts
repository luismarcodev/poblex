import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { OpeningHours } from '../value-objects/opening-hours.vo';
import { Facility, FacilityProps } from './facility.entity';

const SOLLANA_ID = 'a1b2c3d4-e5f6-4789-a012-3456789abcde';

function baseProps(overrides: Partial<FacilityProps> = {}): FacilityProps {
  return {
    id: 'f1b2c3d4-e5f6-4789-a012-3456789abcde',
    municipalityId: MunicipalityId.create(SOLLANA_ID),
    name: LocalizedText.create({ es: 'Pista de pádel' }),
    description: null,
    category: 'Pádel',
    imageUrl: null,
    slotDurationMinutes: 60,
    openingHours: OpeningHours.create({
      mon: { open: '09:00', close: '22:00' },
      tue: { open: '09:00', close: '22:00' },
      wed: { open: '09:00', close: '22:00' },
      thu: { open: '09:00', close: '22:00' },
      fri: { open: '09:00', close: '22:00' },
      sat: { open: '09:00', close: '14:00' },
      sun: null,
    }),
    feeNote: null,
    maxAdvanceBookingDays: 14,
    active: true,
    createdAt: new Date('2026-01-01T00:00:00Z'),
    ...overrides,
  };
}

describe('Facility', () => {
  it('creates a valid facility', () => {
    const facility = Facility.create(baseProps());
    expect(facility.category).toBe('Pádel');
    expect(facility.slotDurationMinutes).toBe(60);
  });

  it('rejects slotDurationMinutes outside 1-480', () => {
    expect(() => Facility.create(baseProps({ slotDurationMinutes: 0 }))).toThrow(
      ValidationError,
    );
    expect(() => Facility.create(baseProps({ slotDurationMinutes: 481 }))).toThrow(
      ValidationError,
    );
  });

  it('rejects a non-positive maxAdvanceBookingDays', () => {
    expect(() => Facility.create(baseProps({ maxAdvanceBookingDays: 0 }))).toThrow(
      ValidationError,
    );
  });

  describe('isWithinBookingWindow', () => {
    const now = new Date('2026-08-13T10:00:00Z');

    it('rejects a slot in the past', () => {
      const facility = Facility.create(baseProps());
      expect(
        facility.isWithinBookingWindow(new Date('2026-08-13T09:00:00Z'), now),
      ).toBe(false);
    });

    it('accepts a slot within the advance-booking window', () => {
      const facility = Facility.create(baseProps({ maxAdvanceBookingDays: 14 }));
      expect(
        facility.isWithinBookingWindow(new Date('2026-08-20T10:00:00Z'), now),
      ).toBe(true);
    });

    it('rejects a slot beyond the advance-booking window', () => {
      const facility = Facility.create(baseProps({ maxAdvanceBookingDays: 14 }));
      expect(
        facility.isWithinBookingWindow(new Date('2026-09-01T10:00:00Z'), now),
      ).toBe(false);
    });
  });
});
