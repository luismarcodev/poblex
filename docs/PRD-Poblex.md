# PRD — Poblex

**Versión:** 1.0
**Fecha:** 30 de julio de 2026
**Pueblo piloto:** Sollana (Valencia, Ribera Baixa)
**Estado:** aprobado para construir demo

---

## 1. Resumen ejecutivo

Poblex es una aplicación móvil (Flutter, iOS + Android) con backoffice web que centraliza la comunicación municipal de pueblos pequeños, hoy fragmentada entre grupos de WhatsApp, tablón físico, megafonía y redes sociales.

Modelo de negocio: **B2G** — paga el ayuntamiento, no el vecino. Referencia de mercado: Bandomovil ~500 €/año con más de 1.200 municipios; eAgora con más de 500 y plan básico gratuito.

Arquitectura de producto: **una sola app Poblex multi-tenant**. El vecino abre la app, elige su municipio y entra. La marca blanca por municipio queda como producto premium futuro, no como opción por defecto.

---

## 2. Objetivo de la primera entrega (demo)

Demostrar al alcalde de Sollana un producto navegable y creíble, con datos reales del municipio, que cubra las siete secciones acordadas. No es una versión de producción: no se abre a vecinos hasta cerrar el marco legal (sección 9).

**Criterio de éxito:** el alcalde entiende el producto sin explicación, identifica su pueblo como propio y aporta feedback concreto sobre el siguiente paso.

---

## 3. Usuarios

| Perfil | Descripción | Acceso |
|---|---|---|
| Vecino | Cualquier persona interesada en el municipio | Libre, sin pantalla de login. Elige municipio al primer arranque |
| Gestor | Persona designada por el ayuntamiento | Backoffice web con email + contraseña |

**Decisión de autenticación:** **ninguna para el vecino**. Sin registro, sin login, sin datos personales. La app genera un UUID en el primer arranque, lo guarda en local y lo envía al backend en cada petición como identificador de dispositivo. Esto permite:
- Un voto por dispositivo en encuestas, garantizado por restricción de unicidad en base de datos (sin ello los resultados no son defendibles ante el ayuntamiento).
- Consulta del estado de las incidencias propias sin pedir datos personales.
- Push segmentado por municipio.

No es una identidad y no autoriza nada sensible: es falsificable y así se asume en el diseño. La autenticación del vecino queda como posibilidad futura.

**El gestor sí se autentica**, sin excepción: email y contraseña, con protección frente a fuerza bruta (bloqueo tras intentos fallidos repetidos) y flujo de recuperación de contraseña. Un backoffice abierto permitiría a cualquiera lanzar una alerta falsa de emergencia en nombre del ayuntamiento — el login de gestor es el punto de entrada más sensible de todo el sistema y se protege como tal.

No se verifica empadronamiento. Consecuencia asumida y a comunicar al alcalde: las encuestas son **consultivas, no vinculantes**, y deben etiquetarse como tal dentro de la app.

**Un dispositivo sigue un único municipio en fase 1.** Seguir varios pueblos a la vez queda fuera del MVP y se aparca para fase 2 — no está prometido en la demo.

---

## 4. Alcance funcional

### 4.1 Core (imprescindible para la demo)

**Noticias**
- Listado cronológico con destacados fijables por el gestor.
- Categoría por noticia (general, sanitaria, etc.) para poder filtrar y para dar soporte a la sección de información sanitaria.
- Detalle con imagen, cuerpo de texto y adjuntos.
- **Visor de PDF nativo dentro de la app**, sin delegar en el visor del sistema (defecto detectado en la competencia).
- **Auto-archivado**: a los 90 días las noticias pasan a la pestaña "Histórico" automáticamente. El vecino nunca tiene que borrar nada a mano (defecto detectado en reseñas de eAgora: la función existía pero no era descubrible).

**Eventos**
- Listado por fecha y vista de calendario mensual.
- Detalle con lugar, horario y descripción.
- Recordatorio push opcional por evento, activado por el vecino. Se envía al dispositivo concreto que lo pidió, no por difusión.

**Alertas**
- Dos orígenes: automático (AEMET) y manual (gestor).
- Automático: integración con **AEMET OpenData**, endpoint de Avisos de Fenómenos Meteorológicos Adversos, por zona geográfica. API pública y gratuita mediante API Key solicitada por correo. Tarea programada en el backend cada 15 minutos, deduplicación por identificador del aviso, publicación automática y push inmediato **sin intervención humana**.
- Manual: el gestor publica alertas sanitarias, cortes de agua, etc.
- Niveles de severidad visualmente diferenciados (amarillo / naranja / rojo).
- Las alertas rojas fuerzan notificación, aunque el usuario tenga otras categorías silenciadas.

**Incidencias (buzón vecinal privado)**
- Formulario: categoría, descripción, foto opcional, ubicación opcional.
- **Privado**: solo visible por el gestor en el backoffice. No hay muro público de incidencias — decisión deliberada para evitar difamación y responsabilidad de moderación.
- Estados: Recibido → En curso → Resuelta, con push al vecino que la reportó en cada cambio (envío dirigido a su dispositivo, no difusión al municipio).
- Límite de envíos por dispositivo e IP, y restricciones de subida de imagen (tamaño y tipo). Sin autenticación de vecino, un endpoint público de escritura sin límite es una invitación a inundarlo.

### 4.2 Módulos adicionales pedidos por el alcalde (incluidos en la demo)

**Encuestas**
- Pregunta, opciones, fecha de cierre, resultados agregados.
- Un voto por dispositivo, garantizado por restricción de unicidad `(survey_id, device_id)` en base de datos.
- Etiqueta visible: "Consulta no vinculante".

**Formularios**
- **Motor genérico configurable**, no un formulario de paellas hardcodeado. El gestor define título, descripción, campos (texto, número, selección, fecha, sí/no) y fecha límite.
- Un solo desarrollo cubre: censo de paellas, inscripción a fiestas, registros de datos no vinculantes futuros.
- Exportación de respuestas a CSV desde el backoffice.

**Farmacias de guardia**
- Calendario de guardias con farmacia, dirección, teléfono y horario.
- **Carga manual mensual por el gestor.** No existe API oficial abierta de la Comunidad Valenciana para este dato; los Colegios de Farmacéuticos publican en web/PDF y los agregadores de terceros son frágiles. Se descarta scraping por riesgo de rotura silenciosa en un dato de interés sanitario.
- Sección de "Información sanitaria de interés" como subcategoría de noticias etiquetada.

### 4.3 Fuera de alcance (fase 2, no prometer al alcalde como incluido)

| Módulo | Motivo del aplazamiento |
|---|---|
| Reservas de pistas municipales | Proyecto en sí mismo: calendario de disponibilidad, prevención de dobles reservas, posible cobro de tasas. Candidato natural a módulo de pago |
| Listado de comercios locales | Requiere definir **quién** mantiene el listado. Sin proceso de actualización queda obsoleto en 3 meses y perjudica la imagen del producto |
| Viajes compartidos | Problema de doble cara: sin masa crítica no hay oferta, sin oferta no hay usuarios. No viable con un solo municipio |
| Compraventa local | Compite con Wallapop/Milanuncios, que ya concentran inventario y confianza |
| Trámites oficiales | Fase 1 se limita a enlaces externos a la sede electrónica existente |
| Seguir varios municipios desde un dispositivo | El esquema de datos de fase 1 es un municipio por dispositivo. Ampliar a N:M es un cambio de modelo, no una opción de configuración |

---

## 5. Accesibilidad — requisito no negociable

El alcalde lo pidió expresamente y además **es obligación legal**: las apps del sector público en España están sujetas al **RD 1112/2018**, que exige nivel **AA de WCAG 2.1**. No es una mejora opcional, es condición de aceptación.

Requisitos concretos:
- Tamaño de cuerpo de texto base 18 sp, escalado dinámico hasta 200 % sin romper el layout.
- Contraste mínimo 4,5:1 en texto normal y 3:1 en texto grande y elementos gráficos.
- Áreas táctiles mínimas de 48 × 48 dp.
- **Ninguna acción exclusiva por gesto.** Todo lo que se pueda hacer deslizando tiene botón visible equivalente.
- Etiquetas semánticas completas para TalkBack y VoiceOver en todos los controles e imágenes.
- Lectura en voz alta del contenido de alertas críticas.
- Jerarquía de navegación plana: máximo dos niveles de profundidad desde el inicio.
- Tipografía **Atkinson Hyperlegible** (diseñada para baja visión, licencia libre) como fuente por defecto.
- Declaración de accesibilidad publicada, exigida por el RD 1112/2018.

---

## 6. Identidad visual

Diseñada para legibilidad institucional, no para tendencia de diseño.

| Elemento | Valor |
|---|---|
| Verde Albufera (primario) | `#1F6F5C` |
| Terracota (acento) | `#C75B39` |
| Hueso (fondo) | `#FAF7F2` |
| Tinta (texto) | `#1A1A1A` |
| Alerta amarilla | `#E8A33D` |
| Alerta naranja | `#D9772B` |
| Alerta roja | `#B3261E` |

Paleta cálida y terrosa, deliberadamente alejada del azul corporativo genérico del sector, con contrastes verificados contra fondo hueso para cumplir AA. Cada municipio puede sobreescribir color primario y logo desde el backoffice (theming multi-tenant), manteniendo la estructura y los contrastes validados.

Logotipo: marca tipográfica "Poblex" con un punto sobre la "o" que evoca un marcador de mapa. Sin ilustración compleja: debe funcionar en 48 px de icono de app.

---

## 7. Arquitectura técnica y modelo de datos

### Arquitectura

| Componente | Tecnología |
|---|---|
| App móvil | Flutter (iOS 15+ / Android 10+), Clean Architecture + DDD + SOLID |
| Backoffice | Flutter Web |
| Backend | NestJS (TypeScript), arquitectura hexagonal + DDD + SOLID, API REST versionada |
| Base de datos | PostgreSQL con Prisma |
| Ficheros | Object storage compatible con S3, jurisdicción UE, subidas por URL prefirmada |
| Push | Firebase Cloud Messaging (único servicio de Firebase utilizado) |
| Despliegue | Contenedor en Railway o Render, **región UE** |

**Sin modo offline**: la app requiere conexión. Toda pantalla tiene estado de error legible con botón de reintentar.

**Entornos**: solo producción durante la fase de demo. Separación de entornos obligatoria antes de abrir la app a vecinos reales.

### Modelo de datos (PostgreSQL)

Relacional y normalizado. El contenido bilingüe se almacena en `jsonb` con forma `{"es": "...", "va": "..."}`.

```
municipalities          id, slug, name, province, aemet_zone_code,
                        primary_color, logo_url, languages[], active
managers                id, email (unique), password_hash, display_name
manager_municipalities  manager_id, municipality_id          -- N:M
devices                 id (uuid de dispositivo), municipality_id,   -- 1:N, un dispositivo = un municipio en fase 1
                        fcm_token, locale, created_at, last_seen_at

news                    id, municipality_id, title jsonb, body jsonb,
                        image_url, category, pinned, published_at, archived
news_attachments        id, news_id, name, url, mime_type

events                  id, municipality_id, title jsonb, description jsonb,
                        start_at, end_at, location_name, lat, lng, category
event_reminders         id, event_id, device_id, remind_at, sent_at
                        UNIQUE (event_id, device_id)

alerts                  id, municipality_id, source, severity, phenomenon,
                        body jsonb, start_at, end_at, aemet_id,
                        created_by (manager_id, null si origen aemet), updated_by
                        UNIQUE (municipality_id, aemet_id)

incidents               id, municipality_id, device_id, category, description,
                        photo_url, photo_purge_at, lat, lng, status,
                        created_at, updated_at
incident_status_history id, incident_id, status, note, changed_at, changed_by

surveys                 id, municipality_id, question jsonb, closes_at, results_visible
survey_options          id, survey_id, label jsonb, position
survey_votes            id, survey_id, option_id, device_id, voted_at
                        UNIQUE (survey_id, device_id)        -- un voto por dispositivo

forms                   id, municipality_id, title jsonb, description jsonb, deadline
form_fields             id, form_id, key, label jsonb, type, required, options jsonb
form_submissions        id, form_id, device_id, submitted_at
form_answers            id, submission_id, field_id, value

duty_pharmacies         id, municipality_id, date, pharmacy_name, address, phone, schedule
                        UNIQUE (municipality_id, date)
```

Toda tabla de contenido lleva `municipality_id` y ninguna consulta se escribe sin filtrar por municipio. Las restricciones de unicidad son la garantía real; la validación en código solo sirve para dar buen mensaje de error.

**Nota sobre el gestor multi-municipio:** la relación `manager_municipalities` es de muchos a muchos desde el principio. En municipios pequeños es habitual que un mismo secretario-interventor atienda varios ayuntamientos agrupados, y el backoffice debe permitirle publicar en varios de golpe sin repetir trabajo. Es la vía natural de expansión: eBando creció por proximidad geográfica, pueblo vecino a pueblo vecino.

### Operación y resiliencia

Un sistema que puede lanzar una alerta de emergencia a todo un municipio no puede fallar en silencio ni carecer de rastro. No es opcional:

- **Monitorización del cron de AEMET.** Sollana está en la Ribera Baixa, zona con historial reciente de inundaciones. Tras 3 fallos consecutivos en la llamada a AEMET, aviso automático por email a la dirección de operaciones. Un fallo de red nunca deja la sección de alertas sin actualizar sin que nadie lo sepa.
- **Auditoría de alertas.** Toda alerta guarda quién la publicó (`created_by`, nulo si el origen es AEMET) y quién la modificó por última vez. Mismo criterio que ya aplicaba a las incidencias.
- **Login de gestor protegido.** Bloqueo temporal tras intentos fallidos repetidos y recuperación de contraseña por email con token de un solo uso. Es el punto de entrada más sensible del sistema.
- **Backups automáticos diarios de PostgreSQL**, retención mínima 7 días diarios + 4 semanales, con una restauración de prueba verificada antes de abrir la app a vecinos reales.
- **Rotación de token de notificaciones** y limpieza periódica de dispositivos inactivos (más de 6 meses sin uso), para no acumular tokens muertos.
- **Límites de peticiones en todos los endpoints públicos de escritura** (incidencias, votos, formularios, alta de dispositivo). El identificador de dispositivo es falsificable y no protege por sí solo; sin límites, cualquiera puede inundar el buzón del ayuntamiento.
- **Restricciones de subida de imágenes**: tamaño máximo, tipos permitidos validados por contenido y redimensionado en servidor.
- **Purga automática de fotos de incidencias** a los 12 meses del cierre, como tarea programada. Es el requisito legal de la sección 9, y sin cron que lo ejecute es solo una intención escrita.

### Tareas programadas

| Tarea | Frecuencia |
|---|---|
| Sincronización de avisos AEMET | Cada 15 minutos |
| Auto-archivado de noticias a los 90 días | Diaria |
| Purga de fotos de incidencias vencidas | Diaria |
| Envío de recordatorios de eventos | Cada 15 minutos |
| Limpieza de dispositivos inactivos | Semanal |

- **Cuentas de Apple Developer Program y Google Play Console a nombre de Luis**, gestionando todos los municipios desde ahí. Implicación a resolver más adelante, no ahora: si un ayuntamiento decide dejar el servicio, la app no se lleva consigo porque la cuenta de tienda no es suya — a documentar en el contrato con cada municipio cuando exista.

---

## 8. Bilingüismo (castellano / valenciano)

- Todos los campos de contenido son objetos `{ es, va }`.
- La app sigue el idioma del dispositivo, con conmutador manual en ajustes.
- **Fallback obligatorio**: si el gestor solo redacta en un idioma, se muestra el disponible con indicación discreta del idioma original. Nunca se muestra un hueco vacío.
- El backoffice presenta los dos campos lado a lado, con el segundo opcional.
- Interfaz (etiquetas, botones) traducida completa en ambos idiomas vía ARB.
- **Las notificaciones push también son bilingües.** Los avisos de difusión se envían por canales separados por idioma; los avisos dirigidos a un vecino concreto usan el idioma guardado en su dispositivo. Un aviso de emergencia en el idioma que el vecino no lee no cumple su función.

---

## 9. Legal — bloqueante antes de datos reales

No se abre la app a vecinos de Sollana hasta cerrar estos puntos:

1. **Contrato de encargo de tratamiento (RGPD).** El ayuntamiento es responsable del tratamiento; el desarrollador es encargado. Obligatorio antes de tratar datos de vecinos.
2. **Política de privacidad y aviso legal** accesibles desde la app y desde las fichas de las tiendas.
3. **Fotos de incidencias**: pueden contener datos personales si aparecen personas o matrículas. Definir política de retención (propuesta: borrado automático a los 12 meses del cierre de la incidencia) y advertencia al vecino en el momento de adjuntar.
4. **Declaración de accesibilidad** conforme al RD 1112/2018.
5. **Encuestas etiquetadas como no vinculantes** de forma visible, dado que no hay verificación de empadronamiento.
6. **Residencia de datos en la UE.** Base de datos, backend y almacenamiento de ficheros desplegados en región europea. Verificar al crear cada servicio; con un ayuntamiento como cliente no es negociable.

---

## 10. Monetización

| Vía | Descripción | Momento |
|---|---|---|
| Piloto gratuito | Sollana sin coste durante 6-12 meses a cambio de feedback constante | Ahora |
| Freemium | Core gratuito (noticias, eventos, alertas, incidencias). Pago por módulos: reservas de instalaciones, formularios avanzados, analítica | Tras el piloto |
| Suscripción anual por tramos de población | Referencia de mercado 500-1.000 €/año | Tras el piloto |
| Contrato con Diputación | Licencia agrupada para todos los municipios pequeños de la provincia. Ciclo de venta largo (meses o años) | Objetivo 1-2 años |
| Marca blanca premium | App propia en tiendas para el municipio que la pague. Coste operativo alto: ficha, revisión y mantenimiento por app | A demanda |

**Ventaja competitiva real frente a Bandomovil / eAgora / eBando:** no es una funcionalidad, es la oferta. Siendo pequeño puedes dar lo que un proveedor con cientos de clientes no puede: piloto gratuito sin plazo, atención directa del desarrollador en horas y producto moldeado con el propio ayuntamiento. Esa es la palanca de entrada.

---

## 11. Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Nadie mantiene el contenido en el ayuntamiento | Muerte del proyecto en 2 meses | Identificar por nombre a la persona gestora antes de lanzar a vecinos. Alertas AEMET automáticas reducen la dependencia |
| Los vecinos no se instalan otra app | Sin usuarios, sin renovación del contrato | Fase 2: notificación por SMS para alertas críticas y "modo cuidador" para que un familiar gestione avisos de un mayor |
| eAgora regala su plan básico | Presión sobre el precio | Competir en cercanía y adaptación, no en precio |
| Rotación de proveedor en el sector | Te pueden desplazar igual que entras | Integración profunda (padrón, instalaciones) eleva el coste de cambio |
| Cambio de gobierno municipal | Pérdida del piloto | Contrato con el ayuntamiento como institución, no acuerdo verbal con el alcalde |
| Cuentas de tienda a nombre de Luis, no del ayuntamiento | Un municipio que se va no puede llevarse "su" app | Documentar la titularidad en el contrato con cada municipio antes de firmar |
