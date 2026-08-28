import { gunzipSync } from 'node:zlib';

export interface ArchiveEntry {
  name: string;
  content: string;
}

const BLOCK_SIZE = 512;
const NAME_OFFSET = 0;
const NAME_LENGTH = 100;
const SIZE_OFFSET = 124;
const SIZE_LENGTH = 12;

// AEMET OpenData entrega los avisos CAP como un tar.gz. El formato tar es
// trivial (cabeceras de 512 bytes con el tamaño en octal) y gzip lo trae
// node:zlib, así que no se añade una dependencia por esto.
export function extractTarGz(buffer: Buffer): ArchiveEntry[] {
  const tar = gunzipSync(buffer);
  const entries: ArchiveEntry[] = [];
  let offset = 0;

  while (offset + BLOCK_SIZE <= tar.length) {
    const name = tar
      .subarray(offset + NAME_OFFSET, offset + NAME_OFFSET + NAME_LENGTH)
      .toString('utf-8')
      .replace(/\0.*$/, '')
      .trim();

    // Dos bloques a cero marcan el final del archivo.
    if (name === '') break;

    const rawSize = tar
      .subarray(offset + SIZE_OFFSET, offset + SIZE_OFFSET + SIZE_LENGTH)
      .toString('utf-8')
      .replace(/\0.*$/, '')
      .trim();
    const size = parseInt(rawSize, 8);
    if (Number.isNaN(size)) break;

    const dataStart = offset + BLOCK_SIZE;
    entries.push({
      name,
      content: tar.subarray(dataStart, dataStart + size).toString('utf-8'),
    });

    // El contenido se rellena hasta completar bloques de 512.
    offset = dataStart + Math.ceil(size / BLOCK_SIZE) * BLOCK_SIZE;
  }

  return entries;
}
