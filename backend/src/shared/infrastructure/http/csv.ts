// Generación de CSV a mano: son treinta líneas y añadir una dependencia por
// esto no se justifica.
//
// Se escapa según RFC 4180: comillas dobles duplicadas y campo entrecomillado
// si contiene separador, comillas o salto de línea. El BOM inicial es lo que
// hace que Excel abra el fichero en UTF-8 en vez de romper los acentos — el
// gestor va a abrir esto con Excel, no con un editor de texto.
const BOM = '﻿';

function escapeField(value: string): string {
  if (/[",\n\r]/.test(value)) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

export function toCsv(headers: string[], rows: string[][]): string {
  const lines = [headers, ...rows].map((row) =>
    row.map((field) => escapeField(field)).join(','),
  );
  return BOM + lines.join('\r\n') + '\r\n';
}
