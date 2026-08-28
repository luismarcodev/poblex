import { toCsv } from './csv';

const BOM = '﻿';

describe('toCsv', () => {
  it('starts with a BOM so Excel reads it as UTF-8', () => {
    const csv = toCsv(['nombre'], [['Sollana']]);

    expect(csv.startsWith(BOM)).toBe(true);
    expect(csv).toContain('Sollana');
  });

  it('quotes fields containing the separator', () => {
    const csv = toCsv(['direccion'], [['Carrer Major, 12']]);

    expect(csv).toContain('"Carrer Major, 12"');
  });

  it('doubles inner quotes', () => {
    const csv = toCsv(['nota'], [['El vecino dijo "urgente"']]);

    expect(csv).toContain('"El vecino dijo ""urgente"""');
  });

  it('quotes fields with line breaks', () => {
    const csv = toCsv(['nota'], [['linea uno\nlinea dos']]);

    expect(csv).toContain('"linea uno\nlinea dos"');
  });

  it('leaves plain fields untouched', () => {
    const csv = toCsv(['a', 'b'], [['1', '2']]);

    expect(csv).toBe(`${BOM}a,b\r\n1,2\r\n`);
  });
});
