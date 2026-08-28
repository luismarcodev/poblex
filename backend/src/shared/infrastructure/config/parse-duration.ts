const UNIT_MS: Record<string, number> = {
  s: 1_000,
  m: 60_000,
  h: 3_600_000,
  d: 86_400_000,
};

// Parsea duraciones tipo "30d", "15m" a milisegundos. Formato de env vars
// como JWT_REFRESH_EXPIRES_IN, que necesitan Date real (no las firma jwt.sign).
export function parseDurationMs(value: string): number {
  const match = /^(\d+)(s|m|h|d)$/.exec(value.trim());
  if (!match) {
    throw new Error(
      `Invalid duration format: "${value}" (expected e.g. "15m", "30d")`,
    );
  }
  const [, amount, unit] = match;
  return Number(amount) * UNIT_MS[unit];
}
