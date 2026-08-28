import { ValidationError } from '../../domain/errors/common-errors';
import {
  MAX_IMAGE_BYTES,
  assertValidImage,
  detectImageType,
} from './image-validation';

function padTo(header: number[], length = 16): Buffer {
  return Buffer.concat([
    Buffer.from(header),
    Buffer.alloc(Math.max(0, length - header.length)),
  ]);
}

const JPEG = padTo([0xff, 0xd8, 0xff, 0xe0]);
const PNG = padTo([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
const WEBP = Buffer.concat([
  Buffer.from('RIFF', 'ascii'),
  Buffer.alloc(4),
  Buffer.from('WEBP', 'ascii'),
  Buffer.alloc(4),
]);

describe('image validation', () => {
  it('detects the three allowed formats by their magic bytes', () => {
    expect(detectImageType(JPEG)).toBe('image/jpeg');
    expect(detectImageType(PNG)).toBe('image/png');
    expect(detectImageType(WEBP)).toBe('image/webp');
  });

  // Validación por CONTENIDO REAL: la extensión y el Content-Type declarado
  // son texto que el atacante controla.
  it('rejects a payload that only pretends to be an image', () => {
    const script = Buffer.from('<?php system($_GET["c"]); ?>', 'utf-8');

    expect(detectImageType(script)).toBeNull();
    expect(() => assertValidImage(script)).toThrow(ValidationError);
  });

  it('rejects an empty file', () => {
    expect(() => assertValidImage(Buffer.alloc(0))).toThrow(ValidationError);
  });

  it('rejects a file over the size limit', () => {
    const oversized = Buffer.concat([JPEG, Buffer.alloc(MAX_IMAGE_BYTES)]);

    expect(() => assertValidImage(oversized)).toThrow(ValidationError);
  });

  it('returns the detected content type for a valid image', () => {
    expect(assertValidImage(PNG)).toBe('image/png');
  });
});
