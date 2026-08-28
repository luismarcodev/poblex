#!/usr/bin/env bash
# Genera .env y .env.production en el servidor con secretos aleatorios.
# Ejecutar UNA vez dentro de /opt/poblex en el VPS.
# No se commitea nunca (ambos ficheros están cubiertos por .env* en .gitignore).
set -euo pipefail
cd "$(dirname "$0")/.."

if [ -f .env.production ]; then
  echo ".env.production ya existe, no se sobrescribe. Bórralo a mano si quieres regenerarlo."
  exit 1
fi

# Sin dominio de Poblex todavía: se sirve por IP. Edita esta variable con la
# IP real del VPS antes de levantar los contenedores (o vuelve a ejecutar
# este script tras borrar .env.production si la cambias más tarde).
VPS_IP="CHANGE_ME_VPS_IP"

POSTGRES_PASSWORD=$(openssl rand -hex 24)
JWT_ACCESS_SECRET=$(openssl rand -hex 32)
JWT_REFRESH_SECRET=$(openssl rand -hex 32)
SOCIAL_TOKEN_ENCRYPTION_KEY=$(openssl rand -base64 32)

# .env -> variables que docker-compose.prod.yml interpola con ${...}
cat > .env <<EOF
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
EOF

# .env.production -> variables de entorno del contenedor api, ver
# backend/src/shared/infrastructure/config/env.validation.ts para el
# contrato completo (obligatorias vs. opcionales).
cat > .env.production <<EOF
NODE_ENV=production
PORT=3000

DATABASE_URL=postgresql://poblex:${POSTGRES_PASSWORD}@postgres:5432/poblex?schema=public

JWT_ACCESS_SECRET=${JWT_ACCESS_SECRET}
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d
JWT_REFRESH_SECRET=${JWT_REFRESH_SECRET}

PASSWORD_RESET_TOKEN_TTL_MIN=60
THROTTLE_LOGIN_LIMIT=5
THROTTLE_LOGIN_TTL_SECONDS=900

CORS_ORIGIN=http://${VPS_IP}:8091
BACKOFFICE_PUBLIC_URL=http://${VPS_IP}:8091

# Object storage (R2) — CHANGE_ME: solo el usuario tiene estas credenciales.
R2_ENDPOINT=CHANGE_ME
R2_BUCKET=CHANGE_ME
R2_ACCESS_KEY=CHANGE_ME
R2_SECRET_KEY=CHANGE_ME
R2_PUBLIC_BASE_URL=CHANGE_ME

# AEMET OpenData — CHANGE_ME: clave solicitada por correo a AEMET.
AEMET_API_KEY=CHANGE_ME
OPS_ALERT_EMAIL=CHANGE_ME

# Firebase Cloud Messaging — CHANGE_ME.
FCM_PROJECT_ID=CHANGE_ME
FCM_CREDENTIALS_JSON=CHANGE_ME

# Meta (redes sociales) — CHANGE_ME.
META_APP_ID=CHANGE_ME
META_APP_SECRET=CHANGE_ME
META_OAUTH_REDIRECT_URI=http://${VPS_IP}:8090/v1/social/oauth/callback
SOCIAL_TOKEN_ENCRYPTION_KEY=${SOCIAL_TOKEN_ENCRYPTION_KEY}
EOF

chmod 600 .env .env.production
echo "Generados .env y .env.production."
echo "Recuerda: 1) editar VPS_IP en este script o sustituirlo a mano en .env.production,"
echo "2) rellenar los CHANGE_ME (R2, AEMET, FCM, Meta) antes de levantar los servicios."
