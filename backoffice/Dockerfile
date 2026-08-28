# Imagen "stable" de Flutter: el proyecto no fija versión de Flutter (solo
# el SDK de Dart en pubspec.yaml, ^3.12.0). Si el equipo empieza a fijar
# versión con fvm/.fvmrc, cambia este tag para que coincida.
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

FROM caddy:2-alpine
COPY --from=build /app/build/web /srv/backoffice
COPY Caddyfile /etc/caddy/Caddyfile
