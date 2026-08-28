import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { OpeningHours } from './opening-hours.vo';

const FULL_WEEK = {
  mon: { open: '09:00', close: '22:00' },
  tue: { open: '09:00', close: '22:00' },
  wed: { open: '09:00', close: '22:00' },
  thu: { open: '09:00', close: '22:00' },
  fri: { open: '09:00', close: '22:00' },
  sat: { open: '09:00', close: '14:00' },
  sun: null,
};

describe('OpeningHours', () => {
  it('accepts a full week with one closed day', () => {
    const hours = OpeningHours.create(FULL_WEEK);
    expect(hours.rangeFor('mon')).toEqual({ open: '09:00', close: '22:00' });
    expect(hours.rangeFor('sun')).toBeNull();
  });

  it('rejects a value that is not an object', () => {
    expect(() => OpeningHours.create('monday')).toThrow(ValidationError);
    expect(() => OpeningHours.create(null)).toThrow(ValidationError);
    expect(() => OpeningHours.create([])).toThrow(ValidationError);
  });

  it('rejects a day where open is not before close', () => {
    expect(() =>
      OpeningHours.create({ ...FULL_WEEK, mon: { open: '22:00', close: '09:00' } }),
    ).toThrow(ValidationError);
  });

  it('rejects malformed time strings', () => {
    expect(() =>
      OpeningHours.create({ ...FULL_WEEK, mon: { open: '9:00', close: '22:00' } }),
    ).toThrow(ValidationError);
    expect(() =>
      OpeningHours.create({ ...FULL_WEEK, mon: { open: '09:00', close: '25:00' } }),
    ).toThrow(ValidationError);
  });

  it('round-trips through toJSON', () => {
    const hours = OpeningHours.create(FULL_WEEK);
    expect(hours.toJSON()).toEqual(FULL_WEEK);
  });

  describe('dayKeyFor', () => {
    it('maps UTC weekdays to mon..sun starting Monday', () => {
      // 2026-08-10 es lunes en UTC.
      expect(OpeningHours.dayKeyFor(new Date('2026-08-10T12:00:00Z'))).toBe(
        'mon',
      );
      expect(OpeningHours.dayKeyFor(new Date('2026-08-16T12:00:00Z'))).toBe(
        'sun',
      );
    });
  });
});
