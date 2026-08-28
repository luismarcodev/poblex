import { ValidationError } from '../../domain/errors/common-errors';

// Límite del CLAUDE.md: 5 MB por fichero.
export const MAX_IMAGE_BYTES = 5 * 1024 * 1024;

export type AllowedImageType = 'image/jpeg' | 'image/png' | 'image/webp';

// Validación por CONTENIDO REAL, no por extensión ni por el Content-Type que
// declare el cliente: ambos son texto que el atacante controla. Se comprueban
// los bytes mágicos de la cabecera del fichero.
export function detectImageType(buffer: Buffer): AllowedImageType | null {
  if (buffer.length < 12) return null;

  // JPEG: FF D8 FF
  if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
    return 'image/jpeg';
  }

  // PNG: 89 50 4E 47 0D 0A 1A 0A
  const pngSignature = Buffer.from([
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a,
  ]);
  if (buffer.subarray(0, 8).equals(pngSignature)) {
    return 'image/png';
  }

  // WebP: "RIFF" .... "WEBP"
  if (
    buffer.subarray(0, 4).toString('ascii') === 'RIFF' &&
    buffer.subarray(8, 12).toString('ascii') === 'WEBP'
  ) {
    return 'image/webp';
  }

  return null;
}

export function assertValidImage(buffer: Buffer): AllowedImageType {
  if (buffer.length === 0) {
    throw new ValidationError('Empty file');
  }
  if (buffer.length > MAX_IMAGE_BYTES) {
    throw new ValidationError(
      `Image exceeds the ${MAX_IMAGE_BYTES / (1024 * 1024)} MB limit`,
    );
  }

  const type = detectImageType(buffer);
  if (!type) {
    throw new ValidationError(
      'Unsupported image format (expected JPEG, PNG or WebP)',
    );
  }
  return type;
}
