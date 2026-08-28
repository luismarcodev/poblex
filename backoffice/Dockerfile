# Solo Caddy sirviendo estático — SIN SDK de Flutter en esta imagen. La build
# (`flutter build web --release`) se hace en local o en CI, donde ya está el
# SDK instalado y no penaliza al servidor; aquí solo se copia el resultado.
# Ver "Despliegue" en CLAUDE.md/AGENTS.md.
FROM caddy:2-alpine
COPY backoffice/build/web /srv/backoffice
COPY Caddyfile /etc/caddy/Caddyfile
