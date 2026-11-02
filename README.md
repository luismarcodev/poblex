# Poblex

App móvil Flutter + backoffice web + backend propio para centralizar la comunicación municipal en pueblos pequeños. Pueblo piloto: Sollana (Valencia).

Guía de trabajo para Codex: [`CODEX.md`](./CODEX.md). Especificación técnica y decisiones detalladas: [`CLAUDE.md`](./CLAUDE.md). Reglas comunes para todos los agentes: [`AGENTS.md`](./AGENTS.md). Referencia funcional/producto: [`docs/PRD-Poblex.md`](./docs/PRD-Poblex.md).

## Estructura

```
app/          Flutter — app del vecino (iOS + Android)
backoffice/   Flutter Web — panel del gestor municipal
backend/      NestJS + Prisma + PostgreSQL
docs/         PRD y documentación
```

## Estado actual

- `backend/`: API funcional con los 8 contextos de fase 1 implementados (municipios, dispositivos, noticias, eventos, alertas, incidencias, encuestas, formularios, farmacias de guardia, comercios locales), verificada contra PostgreSQL real.
- `app/`: **las 8 secciones del vecino están completas y navegables** — Noticias, Eventos, Alertas (con reglas de severidad R1-R5), Incidencias (reporte con foto), Encuestas (votación), Formularios (motor genérico de campos), Farmacias de guardia y Comercios (directorio con galería de fotos y filtro de categoría). Arquitectura Clean + MVVM/Riverpod de punta a punta en cada una: dominio, datos, presentación, inyección de dependencias y router. `flutter analyze` limpio, suite de tests en verde.
- `backoffice/`: Flutter Web con CRUD completo de gestión para noticias, eventos, alertas, incidencias, encuestas, formularios, farmacias de guardia y comercios (con subida múltiple de fotos, reordenar y desactivar).

Pendiente antes de abrir la app a vecinos reales: separar entorno de desarrollo/producción, completar el backoffice, y el recorrido de aceptación en dispositivo real (fase 8 del plan de arranque).

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
cp config/dev.json.example config/dev.json   # rellenar POBLEX_API_BASE_URL
flutter pub get
flutter run --dart-define-from-file=config/dev.json
```

### backoffice/ (gestor)

```
cd backoffice
cp config/dev.json.example config/dev.json
flutter pub get
flutter run -d chrome --web-port 5000 --dart-define-from-file=config/dev.json
```

## Convenciones rápidas

- Commits: conventional commits en inglés (`feat:`, `fix:`, `refactor:`).
- `flutter analyze` limpio en `app/` y `backoffice/`; `tsc --noEmit` + ESLint + Prettier limpios en `backend/` antes de cada commit.
- Nunca commitear `.env`, `config/dev.json` ni credenciales — ver `.gitignore`.
- Cambios de contrato de API (backend) que afectan a `app/`/`backoffice/` van en el mismo commit.

Detalle completo de arquitectura, reglas de negocio y decisiones cerradas: [`CLAUDE.md`](./CLAUDE.md).
