import { isPaginationCursor } from './pagination-cursor.validator';

const ID = '11111111-1111-4111-8111-111111111111';

describe('isPaginationCursor', () => {
  it('accepts canonical UUID and date/UUID cursors', () => {
    expect(isPaginationCursor(Buffer.from(ID).toString('base64url'))).toBe(
      true,
    );
    expect(
      isPaginationCursor(
        Buffer.from(`2026-08-09T12:00:00.000Z|${ID}`).toString('base64url'),
      ),
    ).toBe(true);
  });

  it.each([
    '',
    'not-a-cursor',
    Buffer.from('invalid-id').toString('base64url'),
    Buffer.from(`not-a-date|${ID}`).toString('base64url'),
    `${Buffer.from(ID).toString('base64url')}=`,
  ])('rejects malformed cursor %s', (cursor) => {
    expect(isPaginationCursor(cursor)).toBe(false);
  });
});
