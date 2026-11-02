# Codex project guide — Poblex

This is the working guide for Codex. Read `AGENTS.md` first: it contains the binding language, product, architecture, security, accessibility, branding, and scope rules shared with Claude. `CLAUDE.md` is the detailed project specification and decision record; do not duplicate it here. If instructions conflict, follow `AGENTS.md`, then the product requirements in `docs/PRD-Poblex.md` for product behavior.

## Project map

- `app/`: Flutter mobile app for residents (Android and iOS).
- `backoffice/`: Flutter Web administration for municipal managers.
- `backend/`: NestJS API, Prisma persistence, and PostgreSQL.
- `packages/poblex_design_system/`: shared Flutter colors, typography, theme, and components.
- `docs/`: product, branding, design system, accessibility, and deployment documentation.
- `design/branding/`: source SVG logos and generated app icon artwork.

Read module-specific context before changing that module: `app/README.md`, `backoffice/README.md`, and `backend/README.md`. The Flutter READMEs may lag the implementation; confirm commands and behavior against `pubspec.yaml`, source, and `AGENTS.md` before relying on them.

## Source of truth

1. `AGENTS.md`: instructions applying to every coding agent.
2. `CLAUDE.md`: detailed architecture and closed product decisions; shared reference, not Claude-only behavior.
3. `docs/PRD-Poblex.md`: functional requirements and scope.
4. `docs/branding.md`, `docs/design-system.md`, and `docs/design-system-accessibility.md`: visual tokens and acceptance constraints. Check the code when documenting what is currently implemented.
5. Source code and migrations: actual runtime behavior and schema.

Do not infer that a README's claimed implementation status is current without checking the code. Do not re-open decisions explicitly marked closed in `CLAUDE.md` unless the user asks to change them.

## Typical workflows

### Flutter resident app

Work from `app/`. A feature normally separates `domain/`, `data/`, and `presentation/`; presentation ViewModels are Riverpod `AsyncNotifier`s, while get_it provides use cases and data dependencies. Keep DTOs and Dio inside `data/`. Use hand-written serialization; do not add code generation or `build_runner`.

Localization strings belong in both `app/lib/l10n/app_es.arb` and `app/lib/l10n/app_ca.arb`. Check whether generated localization files are committed and follow repository convention; do not edit generated files as the source of truth.

### Flutter backoffice

Work from `backoffice/`. Preserve the same Clean Architecture boundaries and shared design-system tokens. Manager authorization is scoped to the manager's municipality relationships. Keep navigation URL-driven with go_router and keep the active municipality explicit where a manager can access several.

### Backend or API contract

Work from `backend/`. Keep domain pure TypeScript, application dependent on domain ports, and NestJS/Prisma/HTTP in infrastructure. For a contract change, update backend and affected Flutter clients in the same change. Add a versioned Prisma migration for schema changes; never edit a production database schema by hand. Filter content by municipality at use-case boundaries.

## Run and inspect locally

Use the project-specific development configuration examples when present. Copy them to local ignored files; never commit secrets or real credentials. The Android emulator reaches the host through `10.0.2.2`, not `localhost`; Flutter web API calls also require the configured backend CORS origin. Confirm a safe development database before running migrations or seeds. Do not point development tools at production data.

Codex has the official `dart-flutter` plugin installed. The MCP server and the app runtime are separate: installing the plugin exposes Flutter tools, but does not start or attach an app automatically. For a user-requested visual review, Codex owns preparing the runtime: start an emulator if needed, install/run the target app, launch the backend against a verified safe development database if the screen needs API data, and use MCP to inspect it. Do not ask the user to open the IDE or start the emulator. Do not claim a live review is complete until `listConnectedApps` shows the intended app and a `flutter_driver_command` screenshot has been captured.

For live inspection, use this sequence:

1. Confirm the Dart/Flutter MCP tools are present in this Codex session. If not, the plugin has not loaded into this session; start a new Codex session and check again.
2. Call DTD `listDtdUris`, connect to the URI for the Poblex project (prefer the workspace URI, not a home-directory or unrelated IDE URI), then call `listConnectedApps`.
3. If Poblex is connected, inspect its widget tree with `widget_inspector`; derive finders from that tree and use `flutter_driver_command` for interactions and screenshots. Never guess keys or labels.
4. If no app is connected, check `list_devices`, `list_running_apps`, and the apps installed on the target device. Use the installed Poblex app if it is the requested/current version and can be inspected. If it is already a compatible debug app, attach to it. If it is installed but cannot expose a Dart debug/DTD connection (for example, it is a release build), keep it available as a visual reference and install/run a separate debug copy for MCP inspection. If Poblex is not installed, install/run it. If no emulator is running, start an existing emulator or create one using the installed Android SDK. The user explicitly authorizes preparing the emulator and installing a local debug build for this review; do not stop and ask them to do it. This does not authorize release builds, publishing, deployment, or use of production data.
5. Preserve the correct API configuration. The examples `app/config/dev.json.example` and `backoffice/config/dev.json.example` contain placeholders and point to localhost; do not use them as-is. For an Android emulator the host is `10.0.2.2`. If the backend is required, verify its environment and database target before starting it or seeding data. Never run migrations/seeds against production.
6. Once the debug app is running, connect its DTD session, confirm it appears in `listConnectedApps`, inspect the widget tree, and capture screenshots through Flutter Driver. Continue through the requested screens and fix verified visual defects, then hot reload/restart and recapture to confirm the fix. Do not use desktop UI automation when the user asked for MCP and screenshots.

Hot reload and hot restart update Dart code in an existing debug runtime. Use reload for ordinary widget edits and restart when initialization or global constants require it. The repository rule “Never build after changes” remains in force for routine development and delivery; the user's explicit request to autonomously run the app for live review authorizes a local debug build/install solely to create that review runtime. Never make release builds or deploy without a separate explicit request. Prefer MCP screenshots over desktop control.

## Verification and delivery

Follow the task's requested validation and `AGENTS.md`. Run focused tests for behavior changes, analyzers for changed Flutter modules, and relevant backend checks. Do not run build commands when the project instruction says not to build. Report checks actually run and distinguish source-level validation from device verification.

Before finishing, check `git status` for generated artifacts and unintended changes. Do not discard pre-existing user changes. Keep commit messages conventional English and never add AI attribution.

## Open operational caveat

The repository instructions state that production is the only configured environment and that a separate development environment is required before real residents use the app. Treat emulator data and any existing backend as potentially real until its target is verified. Never use the live municipal database for tests or demo seeding.
