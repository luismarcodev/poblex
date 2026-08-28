import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { LocalizedText } from '../../../../shared/domain/value-objects/localized-text';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { EventCategory } from '../value-objects/event-category.vo';
import { EventProps, MunicipalEvent } from './event.entity';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';

function buildProps(overrides: Partial<EventProps> = {}): EventProps {
  return {
    id: 'event-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    title: LocalizedText.create({ es: 'Fira de Sollana' }),
    description: LocalizedText.create({ es: 'Feria anual' }),
    startAt: new Date('2026-09-12T18:00:00Z'),
    endAt: new Date('2026-09-12T23:00:00Z'),
    locationName: 'Plaça Major',
    lat: 39.27,
    lng: -0.38,
    category: EventCategory.create('fiestas'),
    ...overrides,
  };
}

describe('MunicipalEvent', () => {
  it('rejects an event that ends before it starts', () => {
    expect(() =>
      MunicipalEvent.create(
        buildProps({ endAt: new Date('2026-09-12T17:00:00Z') }),
      ),
    ).toThrow(ValidationError);
  });

  // Media coordenada no ubica nada en un mapa.
  it('rejects half a coordinate', () => {
    expect(() => MunicipalEvent.create(buildProps({ lng: null }))).toThrow(
      ValidationError,
    );
    expect(() => MunicipalEvent.create(buildProps({ lat: null }))).toThrow(
      ValidationError,
    );
  });

  it('accepts an event with no coordinates at all', () => {
    const event = MunicipalEvent.create(buildProps({ lat: null, lng: null }));

    expect(event.lat).toBeNull();
    expect(event.lng).toBeNull();
  });

  it('accepts an event with no end date', () => {
    expect(() =>
      MunicipalEvent.create(buildProps({ endAt: null })),
    ).not.toThrow();
  });

  describe('acceptsReminderAt', () => {
    it('accepts a reminder before the event starts', () => {
      const event = MunicipalEvent.create(buildProps());

      expect(event.acceptsReminderAt(new Date('2026-09-12T17:00:00Z'))).toBe(
        true,
      );
    });

    it('rejects a reminder at or after the start', () => {
      const event = MunicipalEvent.create(buildProps());

      expect(event.acceptsReminderAt(new Date('2026-09-12T18:00:00Z'))).toBe(
        false,
      );
      expect(event.acceptsReminderAt(new Date('2026-09-12T19:00:00Z'))).toBe(
        false,
      );
    });
  });
});
