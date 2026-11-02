# Despliegue en el VPS — guía operativa

Staging por IP, sin dominio todavía. Ver también "Despliegue" en `CLAUDE.md` para
el contexto de por qué está montado así.

## 1. Acceso al VPS

```
IP:     152.228.140.92
Usuario: ubuntu
Clave:   ~/.ssh/bm_vps
Ruta:    /opt/poblex
```

```bash
ssh -i ~/.ssh/bm_vps ubuntu@152.228.140.92
```

El VPS es compartido con Business Manager. Cada proyecto tiene su propia red
Docker, su propio Postgres y sus propios puertos — no se tocan entre sí.

| Servicio | Puerto | Contenedor |
|---|---|---|
| API backend | 8090 | `poblex_api` |
| Backoffice (web) | 8091 | `poblex_web` |
| Postgres | interno, no publicado | `poblex_postgres` |

Business Manager ocupa 80/443 en el mismo host — por eso Poblex usa 8090/8091
en vez de los puertos estándar. Verificar que no hay colisión antes de tocar
puertos:

```bash
ssh -i ~/.ssh/bm_vps ubuntu@152.228.140.92 "docker ps --format '{{.Names}}\t{{.Ports}}'"
```

## 2. Desplegar cambios

Un solo comando, desde el repo en local (necesita el SDK de Flutter, que no
está instalado en el VPS):

```bash
VPS_HOST=ubuntu@152.228.140.92 VPS_SSH_KEY=~/.ssh/bm_vps deploy/deploy.sh
```

Qué hace, en orden:
1. `flutter clean` + `flutter build web --release` del backoffice, con
   `--dart-define=POBLEX_API_BASE_URL` apuntando a la API del VPS.
2. Empaqueta `backend`, `backoffice`, `Caddyfile`, `docker-compose.prod.yml`,
   `deploy` y `packages`, y lo sube por SSH.
3. En el VPS: `docker compose up -d --build` (reconstruye imágenes y
   recrea los contenedores que cambiaron).

**`BACKOFFICE_API_BASE_URL`** se calcula solo a partir de `VPS_HOST`
(`http://<esa-ip>:8090/v1`). Solo hace falta fijarlo a mano si la API vive en
otro sitio:

```bash
BACKOFFICE_API_BASE_URL=http://otra-ip:8090/v1 VPS_HOST=... deploy/deploy.sh
```

⚠️ **Gotcha comprobado en real**: `flutter build web` sin `flutter clean`
antes puede reutilizar una compilación incremental e ignorar un
`--dart-define` distinto al de la build anterior, sin avisar ni fallar. El
build "termina bien" pero el JS compilado lleva la URL vieja. `deploy.sh` ya
hace `flutter clean` por esto — si alguna vez se cambia el script, no quitar
esa línea. Para verificar a ojo que un build llevó el dart-define correcto:

```bash
grep -c "<trozo de la URL esperada>" backoffice/build/web/main.dart.js
```

## 3. Sembrar datos de Sollana

La base de datos de producción **no trae nada por defecto** — ni municipios,
ni gestor de prueba. Sin esto, el dispositivo no puede registrarse (el
municipio no existe) y el backoffice no tiene con quién hacer login.

```bash
ssh -i ~/.ssh/bm_vps ubuntu@152.228.140.92 "docker exec poblex_api npm run db:seed"
```

Es un `upsert` (`backend/prisma/seed.ts`) — se puede ejecutar varias veces sin
duplicar nada. Crea el municipio Sollana y un gestor de demo; las credenciales
están en el propio `seed.ts`, no se repiten aquí para no tener dos fuentes de
verdad. **Cambiar esa contraseña antes de que esto sea de cara a vecinos
reales** — lo dice el propio seed en su cabecera.

## 4. Probar notificaciones push

Dos caminos. El primero prueba solo Firebase → dispositivo. El segundo prueba
la cadena completa (backoffice → backend → FCM → dispositivo), que es la que
de verdad hay que validar antes de cualquier demo.

### 4.1 Desde la consola de Firebase (prueba rápida, salta el backend)

1. [console.firebase.google.com](https://console.firebase.google.com) → proyecto **Poblex** (`poblex-279cc`).
2. *Cloud Messaging* (menú lateral) → *Crear campaña* → *Mensajes de Firebase Notifications*.
3. Rellenar título/texto cualquiera → botón **Enviar mensaje de prueba**.
4. Pegar el token FCM del dispositivo (ver 4.3 para conseguirlo) → **Probar**.
5. El push llega a la bandeja del sistema **aunque la app esté en
   primer plano** — pero el banner propio de la app (el de
   `FirebaseMessaging.onMessage`) NO aparece, porque ese mensaje de prueba no
   lleva `data.type` ni `data.id`, y el handler los exige
   (`firebase_push_notification_service.dart`, método `_toPushMessage`). Es
   comportamiento esperado, no un fallo.

### 4.2 Desde el backoffice (prueba real, end-to-end)

1. Login en `http://152.228.140.92:8091` con el gestor de demo (ver 3).
2. Publicar cualquier noticia, evento o alerta.
3. El backend dispara el push por topic a través de
   `FcmNotificationSenderAdapter`
   (`backend/src/shared/infrastructure/notifications/fcm-notification-sender.adapter.ts`)
   — firma el JWT del service account a mano y lo canjea por un token OAuth2,
   sin traer `firebase-admin` completo.
4. Para que el dispositivo lo reciba tiene que estar suscrito al topic del
   municipio + idioma (`m_{municipalityId}_news_{es|va}` etc.) — la app se
   suscribe sola al elegir municipio, pero si se reinstala el emulador o se
   limpian datos, hay que volver a pasar por la pantalla de selección.
5. Borrar después el contenido de prueba — el backoffice no diferencia entre
   contenido real y de prueba, y Sollana ya tiene datos de demo "reales"
   (ver `backend/prisma/seed.ts`) que no conviene mezclar con basura.

### 4.3 Conseguir el token FCM de un dispositivo de prueba

Una vez el dispositivo se registró (pantalla de municipio pasada, permiso de
notificaciones concedido), el token vive en la tabla `devices`:

```bash
ssh -i ~/.ssh/bm_vps ubuntu@152.228.140.92 \
  "docker exec poblex_postgres psql -U poblex -d poblex -t -A -c \
   \"SELECT fcm_token FROM devices ORDER BY last_seen_at DESC LIMIT 1;\""
```

### 4.4 Levantar un emulador Android para probar

```bash
flutter emulators --launch Pixel_10   # o el id que diga `flutter emulators`
cd app && flutter run -d emulator-5554 --dart-define=POBLEX_API_BASE_URL=http://152.228.140.92:8090
```

Si `flutter doctor` se queja de licencias del SDK sin aceptar:

```bash
flutter doctor --android-licenses
```

Para ver si realmente llegó una notificación al sistema (más fiable que mirar
la pantalla, porque una notificación en bandeja no siempre se ve si la app
está delante):

```bash
adb shell dumpsys notification --noredact | grep -A3 "pkg=es.poblex.poblex"
```

## 5. Problemas ya pisados (para no repetirlos)

- **Backoffice compilado contra `localhost:3000`**: pasó porque `deploy.sh`
  nunca pasaba `--dart-define=POBLEX_API_BASE_URL`. Corregido en el propio
  script (§2). Si un despliegue futuro vuelve a fallar el login con "No se
  puede conectar con el servidor", lo primero es comprobar esto con el
  `grep` de §2 antes de sospechar nada del backend.
- **Base de datos de producción sin municipios**: nadie había ejecutado el
  seed en el VPS. Sin Sollana, ni la app ni el backoffice funcionan — no es
  un bug de código, es un paso de despliegue que faltaba (§3).
- **Firebase Cloud Messaging (V1)**: estuvo marcada como "Inhabilitado" en la
  consola en una lectura con la página aún cargando; recargar antes de dar
  nada por verificado.

## 6. Lo que falta (iOS / APNs)

Sin Mac no hay forma de terminar esto — decisión tomada: lanzamos solo
Android por ahora. Queda hecho hasta donde se puede sin Xcode:

- App iOS registrada en Firebase (`es.poblex.poblex`).
- `GoogleService-Info.plist` descargado, en `app/ios/Runner/` (gitignorado).

Falta, y necesita Mac + cuenta de Apple Developer:
- Añadir el `.plist` al target **Runner** desde Xcode.
- Activar *Push Notifications* + *Background Modes → Remote notifications*
  para `es.poblex.poblex` en Apple Developer.
- Subir una clave APNs `.p8` a Firebase.
