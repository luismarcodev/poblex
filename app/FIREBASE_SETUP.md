# Configuración de Firebase para notificaciones

El código móvil ya está conectado a Firebase Cloud Messaging. Para activar el
envío real faltan únicamente los datos del proyecto de Firebase:

1. Crea en Firebase las aplicaciones Android e iOS con el identificador
   `es.poblex.poblex`.
2. Descarga `google-services.json` y colócalo en `app/android/app/`.
3. Descarga `GoogleService-Info.plist`, añádelo a `app/ios/Runner/` y al target
   **Runner** desde Xcode.
4. En Apple Developer activa **Push Notifications** y **Background Modes →
   Remote notifications** para el identificador de la aplicación. Sube a
   Firebase una clave APNs `.p8`.
5. Crea una cuenta de servicio con permiso para Firebase Cloud Messaging y
   configura en el backend:

   ```text
   FCM_PROJECT_ID=<id-del-proyecto>
   FCM_CREDENTIALS_JSON=<json-completo-en-una-sola-variable>
   ```

La cuenta de servicio es un secreto y nunca debe guardarse en el repositorio.
Los dos ficheros de configuración del cliente identifican el proyecto, pero no
autorizan el envío de notificaciones.

## Comprobación manual

1. Instala la aplicación en un móvil real y elige Sollana.
2. Acepta el permiso de notificaciones.
3. Publica una noticia desde el backoffice.
4. Comprueba el aviso con la aplicación abierta, en segundo plano y cerrada.
5. Pulsa el aviso: debe abrir directamente `/news/<id>`.
