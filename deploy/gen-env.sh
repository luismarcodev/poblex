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

# Integraciones opcionales — DEJAR VACÍAS hasta tener credenciales reales.
# IMPORTANTE: no pongas un placeholder tipo "CHANGE_ME" aquí. Varios módulos
# (NotificationsModule, SocialModule) deciden entre el adaptador real y uno
# falso con "if (config.get('X'))" — cualquier string no vacío cuenta como
# "configurado" y entra al adaptador real, que puede reventar el arranque
# (p. ej. FcmNotificationSenderAdapter hace JSON.parse(FCM_CREDENTIALS_JSON)
# sin comprobar que sea JSON válido). Vacío de verdad = cae al fallback
# (consola / adaptadores Fake), que es el comportamiento correcto sin
# configurar. R2 y AEMET no tienen ese gate (usan valor por defecto ''), así
# que vacíos tampoco rompen el arranque, solo dejan esa función sin efecto.

# Object storage (R2)
R2_ENDPOINT=
R2_BUCKET=
R2_ACCESS_KEY=
R2_SECRET_KEY=
R2_PUBLIC_BASE_URL=

# AEMET OpenData — clave solicitada por correo a AEMET.
AEMET_API_KEY=
OPS_ALERT_EMAIL=

# Firebase Cloud Messaging
FCM_PROJECT_ID=
FCM_CREDENTIALS_JSON=

# Meta (redes sociales)
META_APP_ID=
META_APP_SECRET=
META_OAUTH_REDIRECT_URI=http://${VPS_IP}:8090/v1/social/oauth/callback
SOCIAL_TOKEN_ENCRYPTION_KEY=${SOCIAL_TOKEN_ENCRYPTION_KEY}
EOF

chmod 600 .env .env.production
echo "Generados .env y .env.production."
echo "Recuerda: 1) editar VPS_IP en este script o sustituirlo a mano en .env.production,"
echo "2) rellenar R2/AEMET/FCM/Meta cuando tengas las credenciales reales — déjalas"
echo "   vacías hasta entonces, nunca con un placeholder tipo CHANGE_ME."
