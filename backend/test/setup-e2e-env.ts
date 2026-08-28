// E2E tests must never connect to the regular local database or send real
// notifications. CI can override only the dedicated E2E database URL.
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL =
  process.env.E2E_DATABASE_URL ??
  'postgresql://poblex:poblex_local_dev@localhost:5433/poblex_e2e?schema=public';
process.env.JWT_ACCESS_SECRET = 'poblex-e2e-only-access-secret';
process.env.CORS_ORIGIN = 'http://localhost:5000';
process.env.FCM_PROJECT_ID = '';
process.env.FCM_CREDENTIALS_JSON = '';
