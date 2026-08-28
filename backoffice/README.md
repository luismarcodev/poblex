# Poblex Backoffice

Panel municipal Flutter Web. La primera vertical completa implementada es **Noticias**.

## Ejecutar en desarrollo

```powershell
Copy-Item config/dev.json.example config/dev.json
flutter pub get
flutter run -d chrome --web-port 5000 --dart-define-from-file=config/dev.json
```

El backend debe permitir en `CORS_ORIGIN` el origen exacto donde se sirva Flutter Web y usar `credentials: true`, porque el refresh token vive en una cookie `httpOnly`.

## Flujo disponible

1. Restauración de sesión mediante cookie segura o acceso con correo y contraseña.
2. Carga del perfil y de los municipios asignados al gestor.
3. Cambio de municipio activo y aplicación de su color mediante `BrandPalette`.
4. Listado paginado de noticias, incluidas las archivadas cuando se solicita.
5. Publicación bilingüe en uno o varios municipios.
6. Edición mediante URL navegable, destacado, archivado, restauración y borrado confirmado.

## Arquitectura

Cada funcionalidad separa `domain/`, `data/` y `presentation/`. Dio y los DTO quedan en `data`; los widgets solo hablan con ViewModels Riverpod; casos de uso, repositorios y fuentes de datos se resuelven con `get_it`. Los tokens visuales proceden del paquete local `packages/poblex_design_system` compartido con la app móvil.

No hay generación con `build_runner`. Las únicas clases generadas son las localizaciones oficiales de Flutter a partir de los ARB.
