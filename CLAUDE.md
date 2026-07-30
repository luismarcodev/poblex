# CLAUDE.md — Poblex

## Idioma de trabajo

- **Responde siempre en castellano de España.** Vocabulario peninsular: "ordenador" (no computadora), "móvil" (no celular), "vale" (no okay), "fichero/archivo", "borrar", "actualizar". Evita anglicismos cuando existe término castellano corriente.
- **Código, identificadores, nombres de fichero y mensajes de commit en inglés.** Comentarios en inglés.
- Cadenas de interfaz: nunca hardcodeadas. Siempre en ficheros ARB (`es`, `ca-ES-valencia`).
- Tono: directo, sin rodeos. Si algo es mala idea, dilo y explica por qué. No adornes ni valides por defecto.

## Qué es esto

App móvil Flutter + backoffice web + backend propio para centralizar la comunicación municipal en pueblos pequeños. Cliente: ayuntamientos (B2G). Pueblo piloto: **Sollana** (Valencia).

**Una sola app multi-tenant.** El vecino elige municipio al arrancar. La marca blanca por municipio no es el modelo por defecto.

Referencia funcional: `docs/PRD-Poblex.md`. Ante duda funcional, manda el PRD.

## Monorepo

```
app/          Flutter (iOS + Android)
backoffice/   Flutter Web
backend/      NestJS + Prisma + PostgreSQL
docs/         PRD y documentación
```

Un único repositorio git. Los cambios de contrato de API tocan cliente y servidor a la vez: van en el mismo commit. Dart y TypeScript conviven; cada uno con su gestor de paquetes, sin herramienta común.

## Stack

| Capa | Tecnología |
|---|---|
| App y backoffice | Flutter |
| Estado | Riverpod (**solo capa de presentación**) |
| Inyección de dependencias (Flutter) | get_it (dominio y datos) |
| Cliente HTTP | Dio — contra la API propia |
| Navegación | go_router |
| Generación de código | **Ninguna.** Sin freezed, sin json_serializable, sin build_runner |
| Backend | NestJS (TypeScript) |
| Persistencia | PostgreSQL + Prisma |
| Almacenamiento de ficheros | Object storage compatible con S3, jurisdicción UE, subidas por URL prefirmada |
| Push | Firebase Cloud Messaging (único servicio de Firebase que se usa) |
| Integración externa | AEMET OpenData |
| Despliegue backend | Railway o Render, **región UE** |

**Versiones mínimas soportadas:** Android 10 (API 29) e iOS 15. Decisión de producto: parte del público objetivo son personas mayores con terminales antiguos. No subas el mínimo sin justificarlo.

**Sin modo offline.** La app requiere conexión. No implementes persistencia local de contenido ni cola de escrituras diferidas. Lo que sí es obligatorio: estados de carga y de error explícitos y legibles en todas las pantallas — un fallo de red nunca deja una pantalla en blanco ni un spinner infinito. Mensaje claro y botón de reintentar.

**Entornos:** solo producción por ahora. Antes de abrir la app a vecinos reales hay que separar entorno de desarrollo. No se prueba contra la base de datos donde vive el aviso real de corte de agua.

---

# Arquitectura del backend (NestJS)

**Hexagonal (puertos y adaptadores) + DDD + SOLID.** La regla de dependencia se respeta siempre y sin atajos.

## Capas

```
infrastructure  →  application  →  domain  ←  infrastructure
                                   (nadie sale del dominio)
```

- **`domain/`** — entidades, value objects, eventos de dominio, errores de dominio y **puertos** (interfaces de repositorio y de servicios externos). **Cero imports de NestJS, de Prisma y de cualquier librería de infraestructura.** TypeScript puro. Si un fichero de `domain/` importa `@nestjs/...` o `@prisma/client`, está mal y se corrige.
- **`application/`** — casos de uso. Orquestan el dominio y dependen solo de puertos, nunca de adaptadores.
- **`infrastructure/`** — adaptadores: persistencia con Prisma, controladores HTTP de NestJS, cliente de AEMET, cliente de FCM, almacenamiento de ficheros. Implementan los puertos del dominio.

## Estructura por contexto

```
backend/src/
  contexts/
    news/
      domain/          entities/ value-objects/ ports/ errors/
      application/     use-cases/
      infrastructure/  persistence/prisma/  http/  mappers/
    events/
    alerts/
    incidents/
    surveys/
    forms/
    pharmacies/
    municipalities/
    managers/
  shared/
    domain/            Result, value objects base, errores comunes
    infrastructure/    prisma.service, config, storage, fcm, aemet, cron
```

## Reglas innegociables

- **Prisma es un detalle de infraestructura.** Los modelos generados por Prisma **no son** entidades de dominio. Cada adaptador de persistencia tiene su mapper Prisma ↔ dominio. Si un tipo de `@prisma/client` aparece fuera de `infrastructure/persistence/`, la hexagonal está rota.
- **Los DTO de HTTP no son entidades de dominio.** Otro mapper. La entidad nunca se serializa directamente a la respuesta.
- El dominio define el puerto; la infraestructura lo implementa; NestJS inyecta la implementación por token. La aplicación no sabe qué hay al otro lado.
- Value objects (`MunicipalityId`, `LocalizedText`, `Severity`, `IncidentStatus`, `DeviceId`) **validan en su constructor** y son inmutables. Un `Severity` inválido no llega a existir.
- Reglas de negocio en el dominio, nunca en controladores ni en servicios de NestJS. Ejemplos que van en el dominio: una alerta roja siempre notifica, una noticia de más de 90 días se archiva, una encuesta cerrada no admite votos, un dispositivo vota una sola vez.
- Contratos pequeños y específicos (ISP). Nada de repositorios con veinte métodos.
- Errores: `Result<T>` propio en `shared/domain`, igual que en Flutter. Las excepciones de Prisma o de red se capturan en el adaptador y se traducen a errores de dominio tipados. **No cruzan capas.**

## Contrato de API

- REST versionada bajo `/v1`. OpenAPI generado por NestJS y servido en desarrollo.
- Cabecera `X-Device-Id` (UUID v4) en todas las peticiones del vecino.
- Cabecera `Accept-Language` para resolver idioma; el servidor devuelve el objeto bilingüe completo y el cliente decide, para permitir el conmutador manual.
- Endpoints de gestión bajo `/v1/admin`, protegidos por JWT de gestor.
- Paginación por cursor en todos los listados. Nada de devolver colecciones completas.
- **Alta de dispositivo obligatoria antes de cualquier escritura.** `POST /v1/devices` con `X-Device-Id`, `municipality_id`, `locale` y `fcm_token` opcional. `devices.municipality_id` es NOT NULL: sin municipio elegido el dispositivo no existe, y sin dispositivo no se puede votar, reportar incidencia ni enviar formulario.
- **Cambio de municipio:** `PATCH /v1/devices/{id}`. El backend actualiza `municipality_id` y la app **debe desuscribirse de los topics del municipio anterior** y suscribirse a los nuevos. Un dispositivo suscrito a topics de un pueblo que ya no sigue recibe avisos que no le corresponden.

## Límites de peticiones y de subida

Sin autenticación de vecino, el `X-Device-Id` es falsificable y **no protege nada por sí solo**. Todo endpoint público de escritura lleva límite:

- Incidencias: máximo 5 por dispositivo y hora, 20 por IP y hora.
- Votos en encuestas y envíos de formulario: la restricción `UNIQUE` impide el duplicado, pero el límite por IP evita la creación masiva de dispositivos falsos.
- Alta de dispositivos: máximo 10 por IP y hora.
- **Subida de imágenes**: máximo 5 MB por fichero, solo `image/jpeg`, `image/png` y `image/webp`, validado por contenido real y no solo por extensión. Redimensionado en servidor antes de almacenar.
- Los umbrales son punto de partida; ajústalos con datos reales de uso, no a ojo.

## Autenticación

- **El vecino no se autentica.** Sin registro, sin login, sin datos personales. La app genera un UUID v4 en el primer arranque, lo guarda en almacenamiento local seguro y lo envía en `X-Device-Id`. Es un identificador de dispositivo, no una identidad.
  - Sirve para: un voto por dispositivo en encuestas, consultar las incidencias propias, y recibir push.
  - No sirve para: autorizar nada sensible. Trátalo como dato no fiable — es falsificable y así debe asumirse en el diseño.
- **El gestor sí se autentica**, sin excepción: email y contraseña (hash con argon2), JWT de acceso corto y refresh token. Un panel abierto permitiría a cualquiera lanzar una alerta falsa de emergencia en nombre del ayuntamiento.
  - **Rate-limiting en login** con `@nestjs/throttler`: máximo 5 intentos cada 15 minutos por IP + email, bloqueo temporal tras superarlo. El login de gestor es la puerta de entrada más sensible del sistema; no queda sin proteger.
  - **Recuperación de contraseña**: token de un solo uso, caducidad 1 hora, enviado por email. Sin esto, un gestor bloqueado fuera de su cuenta no tiene forma de recuperarla salvo intervención manual en base de datos.
- El gestor solo lee y escribe en los municipios de su relación `manager_municipalities`. Se comprueba en el caso de uso, no solo en el controlador.

## Modelo de datos (PostgreSQL)

Relacional y normalizado. El bilingüe se guarda en `jsonb` con forma `{"es": "...", "va": "..."}`.

```
municipalities        id, slug, name, province, aemet_zone_code,
                      primary_color, logo_url, languages[], active
managers              id, email (unique), password_hash, display_name
manager_municipalities manager_id, municipality_id            -- N:M, PK compuesta
devices               id (uuid del dispositivo), municipality_id,   -- 1:N, un dispositivo = un municipio en fase 1
                      fcm_token, locale, created_at, last_seen_at

news                  id, municipality_id, title jsonb, body jsonb,
                      image_url, category, pinned, published_at, archived
                      -- category: 'general' | 'sanitaria' | ... (etiqueta de subcategoría)
news_attachments      id, news_id, name, url, mime_type

events                id, municipality_id, title jsonb, description jsonb,
                      start_at, end_at, location_name, lat, lng, category
event_reminders       id, event_id, device_id, remind_at, sent_at
                      UNIQUE (event_id, device_id)             -- un recordatorio por dispositivo

alerts                id, municipality_id, source ('aemet'|'manual'),
                      severity ('amarillo'|'naranja'|'rojo'), phenomenon,
                      body jsonb, start_at, end_at, aemet_id,
                      created_by (manager_id, null si origen aemet), updated_by
                      UNIQUE (municipality_id, aemet_id)       -- deduplicación

incidents             id, municipality_id, device_id, category, description,
                      photo_url, photo_purge_at, lat, lng, status,
                      created_at, updated_at
incident_status_history id, incident_id, status, note, changed_at, changed_by

surveys               id, municipality_id, question jsonb, closes_at, results_visible
survey_options        id, survey_id, label jsonb, position
survey_votes          id, survey_id, option_id, device_id, voted_at
                      UNIQUE (survey_id, device_id)            -- un voto por dispositivo

forms                 id, municipality_id, title jsonb, description jsonb, deadline
form_fields           id, form_id, key, label jsonb, type, required, options jsonb, position
form_submissions      id, form_id, device_id, submitted_at
form_answers          id, submission_id, field_id, value

duty_pharmacies       id, municipality_id, date, pharmacy_name, address, phone, schedule
                      UNIQUE (municipality_id, date)
```

- **Toda tabla de contenido lleva `municipality_id`.** Ninguna consulta se escribe sin filtrar por municipio. El aislamiento entre municipios se verifica en el caso de uso.
- Las restricciones `UNIQUE` son la garantía real, no la validación en código. La aplicación valida antes para dar buen mensaje de error; la base de datos garantiza.
- Migraciones con Prisma Migrate, versionadas y en el repo. Nunca se toca el esquema a mano en producción.

## Auditoría, backups y titularidad — no opcional en un sistema de alertas de emergencia

- **`alerts` lleva `created_by` y `updated_by`** (id de gestor, `null` si el origen es AEMET). Mismo patrón que `incident_status_history`. Un sistema que puede notificar una emergencia a todo un municipio necesita saber siempre quién publicó qué.
- **Backups de PostgreSQL**: automáticos diarios del proveedor gestionado (Railway/Render), retención mínima 7 días diarios + 4 semanales. **Obligatorio probar una restauración real antes de abrir la app a vecinos** — un backup nunca verificado no es un backup, es una suposición.
- **Titularidad de las cuentas de Apple Developer Program y Google Play Console: a nombre de Luis**, no del ayuntamiento. Se gestionan todos los municipios desde las mismas cuentas. Riesgo anotado para más adelante, no resuelto ahora: si un ayuntamiento quiere irse, la app no se "lleva" con él porque la cuenta de tienda no es suya. Documentarlo en el contrato con el municipio cuando exista.

## Integración AEMET

- API pública y gratuita, requiere API Key solicitada por correo. Va en variables de entorno del backend, **nunca en el repo ni en el cliente**.
- Endpoint de avisos de fenómenos meteorológicos adversos, por zona. `municipalities.aemet_zone_code` guarda el código. **Verifica el código real de Sollana contra la documentación de AEMET antes de darlo por bueno; no lo inventes.**
- Tarea programada cada 15 minutos en el backend. Deduplicación por `aemet_id` antes de insertar.
- **Monitorización del cron.** Sollana está en la Ribera Baixa, zona con historial reciente de inundaciones — un fallo silencioso en la fuente de alertas meteorológicas no es tolerable. Tras 3 fallos consecutivos de la llamada a AEMET, email automático a la dirección de operaciones configurada. Endpoint `GET /v1/health/aemet` expone el timestamp de la última ejecución correcta, para poder vigilarlo desde fuera.
- Alertas rojas fuerzan push aunque el usuario tenga otras categorías silenciadas.
- Si la llamada falla, se registra el error y cuenta para el umbral de fallos consecutivos anterior. En el cliente, un fallo de AEMET nunca deja la pantalla de alertas rota: se sigue mostrando el histórico ya cargado con el estado de error habitual (mensaje + reintentar).
- El cliente de AEMET es un adaptador que implementa un puerto del dominio. El dominio no sabe que AEMET existe.

## Notificaciones

**Dos mecanismos distintos, no confundirlos.** Un topic de FCM entrega la misma carga a todos sus suscriptores: no permite personalizar idioma ni destinatario. Por eso hay envío por topic y envío por token, y cada caso usa el suyo.

**Difusión (por topic)** — contenido igual para todo el municipio:
- Topics con idioma incluido: `m_{municipalityId}_news_es`, `m_{municipalityId}_news_va`, y equivalentes para `_events` y `_alerts`.
- **El idioma va en el nombre del topic, no en la carga.** Sin esto es imposible mandar el aviso en castellano a unos vecinos y en valenciano a otros. La app se suscribe al topic del idioma activo y cambia de suscripción cuando el usuario cambia de idioma.

**Dirigido (por token, a un dispositivo concreto)** — nunca por topic:
- Cambio de estado de una incidencia: solo lo recibe el vecino que la reportó, en su idioma, leyendo `devices.locale` y `devices.fcm_token`.
- Recordatorio de evento: solo los dispositivos con fila en `event_reminders`.
- Estos envíos NO tienen topic. Si ves `m_{id}_incidents` en algún sitio, está mal.

**Reglas comunes:**
- El envío se dispara desde el caso de uso a través de un puerto, no desde el controlador.
- El usuario puede silenciar categorías **excepto alertas rojas** (desuscripción del topic correspondiente).
- Cada push abre la pantalla de detalle (deep link), no la de inicio.
- **Rotación de `fcm_token`**: endpoint para que la app lo actualice cuando cambie (reinstalación, cambio de dispositivo). Un token viejo sin invalidar es un push que nunca llega y nadie se entera de por qué.
- Al cambiar de municipio o de idioma, la app se desuscribe de los topics antiguos antes de suscribirse a los nuevos.

## Tareas programadas

Todas viven en `shared/infrastructure/cron`, cada una invocando un caso de uso. Ninguna contiene lógica de negocio.

| Tarea | Frecuencia | Qué hace |
|---|---|---|
| Sincronización AEMET | Cada 15 min | Descarga avisos, deduplica por `aemet_id`, publica alerta y dispara push |
| Auto-archivado de noticias | Diaria | Marca `archived = true` las noticias con `published_at` de más de 90 días |
| Purga de fotos de incidencias | Diaria | Borra del almacenamiento las fotos con `photo_purge_at` vencido (12 meses tras el cierre de la incidencia) y limpia `photo_url`. Requisito legal, no mejora |
| Recordatorios de eventos | Cada 15 min | Envía por token los `event_reminders` con `remind_at` vencido y `sent_at` nulo |
| Limpieza de dispositivos | Semanal | Elimina dispositivos con `last_seen_at` de más de 6 meses y sus tokens muertos |

Cada tarea registra su última ejecución correcta. Un fallo repetido en cualquiera de ellas es un fallo silencioso hasta que alguien lo mira: la de AEMET tiene además aviso por email (ver más arriba).

---

# Arquitectura de la app Flutter

**Clean Architecture pura + DDD + SOLID.** Misma filosofía que el backend: dominio aislado, dependencias hacia dentro.

## Capas

```
presentation  →  domain  ←  data
```

- **`domain/`** — entidades, value objects, contratos de repositorio, casos de uso, errores. **Cero imports de Flutter, de Dio y de cualquier infraestructura.** Dart puro.
- **`data/`** — implementaciones: datasources contra la API con Dio, DTO y mappers.
- **`presentation/`** — widgets, providers de Riverpod, controladores. Habla con el dominio vía casos de uso, nunca con repositorios ni datasources.

## Estructura

```
app/lib/features/news/
  domain/
    entities/          news_item.dart
    value_objects/     localized_text.dart
    repositories/      news_repository.dart        // abstracto
    usecases/          get_news.dart
  data/
    datasources/       news_remote_datasource.dart // Dio
    models/            news_item_model.dart        // fromJson/toJson a mano
    mappers/           news_item_mapper.dart
    repositories/      news_repository_impl.dart
  presentation/
    providers/ screens/ widgets/
```

Transversal en `app/lib/core/`: `Result`, errores, configuración de Dio, tema, accesibilidad, gestión del `X-Device-Id`.

## Sin generación de código

- `fromJson` / `toJson` escritos a mano en los DTO de `data/models/`.
- `copyWith` manual donde haga falta.
- **Igualdad con `Equatable`** en entidades y value objects. Es la única concesión, y no es un generador.
- **Los DTO nunca salen de `data/`.** La presentación jamás ve un modelo de datos.
- Sin `build_runner`. Si algo parece necesitar codegen, escríbelo a mano.

## Errores

- `Result<T>` propio en `core/`: `Success<T>` o `Failure<T>` con error de dominio tipado (`NetworkFailure`, `NotFoundFailure`, `ValidationFailure`, `ServerFailure`).
- El adaptador captura `DioException` y la traduce. Fuera de `data/` no hay `try/catch` alrededor de infraestructura.
- La presentación hace pattern matching sobre el `Result`. Todo error tiene mensaje legible en ambos idiomas.

## MVVM en la capa de presentación

MVVM organiza `presentation/` por dentro. No sustituye a Clean Architecture: convive con ella.

- **View** — el widget. Pinta estado y emite intenciones. **Sin lógica de negocio, sin condicionales de dominio, sin llamar a casos de uso directamente.**
- **ViewModel** — **el `AsyncNotifier` de Riverpod es el ViewModel.** No se crea una clase adicional. Mantiene el estado de pantalla, invoca casos de uso resueltos desde get_it y traduce el `Result` a estado de UI.
- **Model** — entidades de dominio. Los DTO nunca llegan aquí.

Reglas:

- **El ViewModel no importa widgets ni conoce `BuildContext`.** Si lo necesita, está haciendo trabajo de la View. Esta regla es lo que permite testearlo sin widget tests.
- **El ViewModel habla con casos de uso, nunca con repositorios ni datasources.**
- Cada pantalla tiene su **estado inmutable propio** (`NewsUiState` con Equatable), no `AsyncValue` con la entidad suelta dentro. Los estados vacío, de filtro y de paginación se modelan explícitamente.
- Nomenclatura: `NewsViewModel extends AsyncNotifier<NewsUiState>`, expuesto como `newsViewModelProvider`.
- La navegación se dispara desde la View con go_router, no desde el ViewModel.

## Inyección de dependencias

- **get_it** registra dominio y datos: datasources, repositorios y casos de uso. Un `injection_container.dart` por feature, agregados desde `configureDependencies()`.
- **Riverpod solo en presentación.** Un provider puede resolver un caso de uso desde get_it, pero **get_it nunca conoce Riverpod**.
- Ningún widget llama a `getIt<T>()` directamente. Siempre a través de un provider.
- `AsyncNotifierProvider` para estado con carga remota, `Provider` para dependencias. Nada de `StateProvider` mutable suelto.

---

# Accesibilidad — condición de aceptación, no mejora opcional

Obligación legal (RD 1112/2018, WCAG 2.1 nivel AA) y petición expresa del alcalde. Todo código nuevo cumple:

- Fuente base 18 sp. Escalado hasta 200 % sin desbordes. **Nunca uses tamaños fijos que ignoren `MediaQuery.textScaler`.**
- Contraste mínimo 4,5:1 en texto normal, 3:1 en texto grande y elementos gráficos.
- Áreas táctiles mínimas 48 × 48 dp.
- **Ninguna acción solo por gesto.** Todo lo que se haga deslizando tiene botón visible equivalente. Sin excepciones.
- `Semantics` en todos los controles e imágenes con contenido. Etiquetas descriptivas, no "botón".
- Navegación de máximo dos niveles desde el inicio.
- Fuente por defecto: **Atkinson Hyperlegible**.
- Verifica con TalkBack o VoiceOver antes de dar por hecha cualquier pantalla nueva.

# Bilingüismo

- Contenido como `jsonb` `{es, va}` en base de datos y objeto `LocalizedText` en el dominio.
- **Fallback obligatorio**: si falta un idioma, muestra el disponible con indicación discreta del idioma original. Jamás un hueco vacío ni "null".
- Interfaz traducida completa vía ARB. Al añadir una cadena, añádela a los dos ficheros en el mismo commit.

# Identidad visual

| Elemento | Valor |
|---|---|
| Verde Albufera (primario) | `#1F6F5C` |
| Terracota (acento) | `#C75B39` |
| Hueso (fondo) | `#FAF7F2` |
| Tinta (texto) | `#1A1A1A` |
| Alerta amarilla | `#E8A33D` |
| Alerta naranja | `#D9772B` |
| Alerta roja | `#B3261E` |

Cada municipio puede sobreescribir color primario y logo desde el backoffice, manteniendo estructura y contrastes validados.

# Decisiones cerradas — no las reabras

- **Sin autenticación del vecino.** UUID de dispositivo en `X-Device-Id`, invisible para el usuario.
- **Un voto por dispositivo** en encuestas, garantizado por restricción `UNIQUE` en base de datos. Sin verificación de empadronamiento, así que las encuestas se etiquetan visiblemente como **no vinculantes**.
- **Incidencias privadas.** Solo el gestor las ve. No existe listado público de incidencias.
- **Formularios con motor genérico configurable**, no formularios hardcodeados por caso de uso.
- **Farmacias de guardia: carga manual** por el gestor. No hay API oficial abierta en la Comunidad Valenciana y no se hace scraping de terceros para un dato sanitario.
- **Auto-archivado de noticias a los 90 días.** El vecino nunca gestiona borrados a mano.
- **Visor de PDF nativo dentro de la app**, no delegado al sistema operativo.
- **`manager_municipalities` es N:M.** El backoffice soporta que un gestor lleve varios municipios y publique en varios de golpe. No asumas nunca un municipio por gestor.
- **Un dispositivo sigue un único municipio en fase 1.** `devices.municipality_id` es una FK simple, no una tabla intermedia. Seguir varios pueblos a la vez es fase 2 y supone cambiar el modelo, no activar una opción.
- Fuera de alcance en fase 1: reservas de instalaciones, comercios locales, viajes compartidos, compraventa. No los implementes salvo instrucción explícita.

# Backoffice — funciones mínimas

- Login de gestor con recuperación de contraseña.
- CRUD de noticias (con adjuntos y categoría), eventos, alertas manuales, encuestas, formularios y farmacias de guardia.
- Bandeja de incidencias con filtro por estado y categoría, y cambio de estado con nota (queda registrado en `incident_status_history`).
- **Exportación a CSV de las respuestas de formularios y de los resultados de encuestas.** Prometido en el PRD: el gestor necesita sacar el censo de paellas a una hoja de cálculo.
- Selector de municipio cuando el gestor tiene varios, y publicación simultánea en varios municipios de su relación.
- Editor bilingüe con los dos idiomas lado a lado, el segundo opcional.

# Datos de la demo

Sollana con contenido real: nombres de calles, plazas y eventos reales del municipio. **Nada de "Lorem ipsum"** — que el alcalde reconozca su pueblo es parte del objetivo.

# Convenciones

- Commits: conventional commits en inglés (`feat:`, `fix:`, `refactor:`).
- Tests: unitarios en dominio y casos de uso (ambos lados), de integración en los adaptadores de persistencia, widget tests en las pantallas del core. Nada de lógica de negocio sin test.
- Flutter: `dart format` y `flutter analyze` limpio antes de cada commit.
- Backend: ESLint y Prettier limpios; `tsc --noEmit` sin errores.
- No introduzcas dependencias nuevas sin justificarlo.
- Nunca commitees claves, tokens, `.env` ni credenciales de FCM.

# Al terminar cualquier tarea

1. `flutter analyze` y build del backend sin errores ni avisos.
2. Cadenas nuevas en ambos ARB.
3. Migración de Prisma creada si tocaste el esquema.
4. Contrato de API y cliente Dio actualizados en el mismo commit.
5. Verificación de accesibilidad en pantallas nuevas (escalado de texto y lector de pantalla).
