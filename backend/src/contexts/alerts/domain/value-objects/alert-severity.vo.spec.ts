import { ValidationError } from '../../../../shared/domain/errors/common-errors';
import { AlertSeverity } from './alert-severity.vo';

describe('AlertSeverity', () => {
  it('accepts the three AEMET levels regardless of casing', () => {
    expect(AlertSeverity.create('ROJO').value).toBe('rojo');
    expect(AlertSeverity.create(' naranja ').value).toBe('naranja');
    expect(AlertSeverity.create('amarillo').value).toBe('amarillo');
  });

  it('refuses to exist with an unknown level', () => {
    expect(() => AlertSeverity.create('verde')).toThrow(ValidationError);
  });

  // Regla de negocio: una alerta roja notifica siempre, aunque el vecino
  // tenga las alertas silenciadas.
  it('forces notification only for the red level', () => {
    expect(AlertSeverity.create('rojo').forcesNotification).toBe(true);
    expect(AlertSeverity.create('naranja').forcesNotification).toBe(false);
    expect(AlertSeverity.create('amarillo').forcesNotification).toBe(false);
  });

  it('orders levels by seriousness', () => {
    const red = AlertSeverity.create('rojo');
    const yellow = AlertSeverity.create('amarillo');

    expect(red.isAtLeast(yellow)).toBe(true);
    expect(yellow.isAtLeast(red)).toBe(false);
  });
});
