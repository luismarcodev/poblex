# Poblex

App móvil Flutter + backoffice web + backend propio para centralizar la comunicación municipal en pueblos pequeños. Pueblo piloto: Sollana (Valencia).

Especificación técnica completa: [`CLAUDE.md`](./CLAUDE.md). Referencia funcional/producto: [`docs/PRD-Poblex.md`](./docs/PRD-Poblex.md). Ante cualquier duda de arquitectura o alcance, esos dos documentos mandan.

## Estructura

```
app/          Flutter — app del vecino (iOS + Android)
backoffice/   Flutter Web — panel del gestor municipal
backend/      NestJS + Prisma + PostgreSQL
docs/         PRD y documentación
```

## Arrancar cada subproyecto

### backend/

```
cd backend
npm install
cp .env.example .env   # rellenar DATABASE_URL (Neon), JWT secrets, R2, etc.
npx prisma migrate dev
npx prisma db seed
npm run start:dev       # http://localhost:3000/v1/health
```

Swagger/OpenAPI disponible en desarrollo en `/api` (ver `main.ts`).

### app/ (vecino)

```
cd app
cp config/dev.json.example config/dev.json   # rellenar API_BASE_URL
flutter pub get
flutter run --dart-define-from-file=config/dev.json
```

### backoffice/ (gestor)

```
cd backoffice
cp config/dev.json.example config/dev.json
flutter pub get
flutter run -d chrome --dart-define-from-file=config/dev.json
```

## Convenciones rápidas

- Commits: conventional commits en inglés (`feat:`, `fix:`, `refactor:`).
- `flutter analyze` limpio en `app/` y `backoffice/`; `tsc --noEmit` + ESLint + Prettier limpios en `backend/` antes de cada commit.
- Nunca commitear `.env`, `config/dev.json` ni credenciales — ver `.gitignore`.
- Cambios de contrato de API (backend) que afectan a `app/`/`backoffice/` van en el mismo commit.

Detalle completo de arquitectura, reglas de negocio y decisiones cerradas: [`CLAUDE.md`](./CLAUDE.md).
