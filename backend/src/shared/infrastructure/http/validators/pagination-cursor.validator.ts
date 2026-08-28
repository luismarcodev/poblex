import {
  buildMessage,
  ValidateBy,
  type ValidationOptions,
} from 'class-validator';

const UUID_V4 =
  /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const BASE64URL = /^[A-Za-z0-9_-]+$/;
const MAX_CURSOR_LENGTH = 512;

export function isPaginationCursor(value: unknown): boolean {
  if (
    typeof value !== 'string' ||
    value.length === 0 ||
    value.length > MAX_CURSOR_LENGTH ||
    !BASE64URL.test(value)
  ) {
    return false;
  }

  const decoded = Buffer.from(value, 'base64url').toString('utf8');
  // Reject permissive/ambiguous base64 decoding. All cursors emitted by the
  // repositories use Node's unpadded canonical base64url representation.
  if (Buffer.from(decoded).toString('base64url') !== value) return false;

  const parts = decoded.split('|');
  if (parts.length === 1) return UUID_V4.test(parts[0]);
  if (parts.length !== 2 || !UUID_V4.test(parts[1])) return false;

  const date = new Date(parts[0]);
  return !Number.isNaN(date.getTime()) && date.toISOString() === parts[0];
}

export function IsPaginationCursor(
  validationOptions?: ValidationOptions,
): PropertyDecorator {
  return ValidateBy(
    {
      name: 'isPaginationCursor',
      validator: {
        validate: isPaginationCursor,
        defaultMessage: buildMessage(
          (eachPrefix) => `${eachPrefix}$property must be a valid cursor`,
          validationOptions,
        ),
      },
    },
    validationOptions,
  );
}
