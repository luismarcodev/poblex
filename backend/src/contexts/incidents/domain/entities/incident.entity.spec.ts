import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { DeviceId } from '../../../../shared/domain/value-objects/device-id';
import { MunicipalityId } from '../../../../shared/domain/value-objects/municipality-id';
import { IncidentStatus } from '../value-objects/incident-status.vo';
import {
  Incident,
  IncidentProps,
  PHOTO_RETENTION_DAYS,
} from './incident.entity';

const MUNICIPALITY_ID = '4f6c9d2e-1a3b-4c5d-8e9f-0a1b2c3d4e5f';
const DEVICE_ID = '7c9e6679-7425-40de-944b-e07fc1f90ae7';
const OTHER_DEVICE_ID = '1b4e28ba-2fa1-41d3-9a5b-e07fc1f90ae7';

function buildProps(overrides: Partial<IncidentProps> = {}): IncidentProps {
  return {
    id: 'incident-1',
    municipalityId: MunicipalityId.create(MUNICIPALITY_ID),
    deviceId: DeviceId.create(DEVICE_ID),
    category: 'alumbrado',
    description: 'Farola fundida en la Plaça Major',
    photoUrl: 'https://cdn.example/incidents/photo.jpg',
    photoPurgeAt: null,
    lat: 39.27,
    lng: -0.38,
    status: IncidentStatus.received(),
    createdAt: new Date('2026-02-01T10:00:00Z'),
    updatedAt: new Date('2026-02-01T10:00:00Z'),
    ...overrides,
  };
}

describe('Incident', () => {
  it('rejects an empty description', () => {
    expect(() => Incident.create(buildProps({ description: '   ' }))).toThrow(
      ValidationError,
    );
  });

  it('trims the description it stores', () => {
    const incident = Incident.create(
      buildProps({ description: '  Farola rota  ' }),
    );

    expect(incident.description).toBe('Farola rota');
  });

  it('rejects half a coordinate', () => {
    expect(() => Incident.create(buildProps({ lat: null }))).toThrow(
      ValidationError,
    );
  });

  // Las incidencias son privadas: solo las ve el gestor y quien la reportó.
  it('only belongs to the device that reported it', () => {
    const incident = Incident.create(buildProps());

    expect(incident.belongsToDevice(DeviceId.create(DEVICE_ID))).toBe(true);
    expect(incident.belongsToDevice(DeviceId.create(OTHER_DEVICE_ID))).toBe(
      false,
    );
  });

  describe('photoPurgeDateFor', () => {
    // Requisito legal: 12 meses tras el cierre y se borra.
    it('schedules the purge one retention period after resolution', () => {
      const incident = Incident.create(buildProps());
      const resolvedAt = new Date('2026-03-01T00:00:00Z');

      const purgeAt = incident.photoPurgeDateFor(resolvedAt);

      expect(purgeAt).toEqual(
        new Date(resolvedAt.getTime() + PHOTO_RETENTION_DAYS * 86_400_000),
      );
    });

    it('schedules nothing when there is no photo to purge', () => {
      const incident = Incident.create(buildProps({ photoUrl: null }));

      expect(
        incident.photoPurgeDateFor(new Date('2026-03-01T00:00:00Z')),
      ).toBeNull();
    });
  });
});
