#!/usr/bin/env bash
# Despliega/actualiza Poblex en el VPS.
#
# A diferencia de bootstrap.sh y gen-env.sh (que corren DENTRO del VPS), este
# script se ejecuta EN LOCAL: el backoffice necesita el SDK de Flutter para
# compilarse (`flutter build web`), y eso no se instala en el servidor — el
# Dockerfile de backoffice solo espera el estático ya compilado. Ver
# "Despliegue" en CLAUDE.md/AGENTS.md.
#
# Uso:
#   VPS_HOST=ubuntu@<ip-o-dominio> deploy/deploy.sh
#   VPS_SSH_KEY=~/.ssh/otra_clave VPS_HOST=... deploy/deploy.sh   # clave distinta
#   BACKOFFICE_API_BASE_URL=http://otra-ip:8090/v1 deploy/deploy.sh  # URL de API distinta
set -euo pipefail
cd "$(dirname "$0")/.."

: "${VPS_HOST:?Define VPS_HOST, p.ej. VPS_HOST=ubuntu@1.2.3.4 deploy/deploy.sh}"
VPS_SSH_KEY="${VPS_SSH_KEY:-$HOME/.ssh/bm_vps}"
VPS_PATH="${VPS_PATH:-/opt/poblex}"
# Sin esto, el backoffice compilado cae al valor por defecto de
# ApiConfig.baseUrl (http://localhost:3000/v1) y no puede hablar con el
# backend real — pasó en despliegue real, no es un caso hipotético.
BACKOFFICE_API_BASE_URL="${BACKOFFICE_API_BASE_URL:-http://${VPS_HOST#*@}:8090/v1}"

echo "== flutter build web (API: $BACKOFFICE_API_BASE_URL) =="
# flutter clean es obligatorio aquí: un build incremental puede ignorar un
# --dart-define distinto al de la build anterior y dejar colado el valor
# viejo sin avisar. Comprobado en despliegue real — build "correcto" en
# apariencia, pero con localhost:3000 todavía dentro del main.dart.js.
(cd backoffice && flutter clean && flutter build web --release \
  --dart-define=POBLEX_API_BASE_URL="$BACKOFFICE_API_BASE_URL")

echo "== empaquetar y subir por SSH =="
tar -czf - \
  --exclude='node_modules' --exclude='dist' --exclude='coverage' --exclude='.dart_tool' \
  backend backoffice Caddyfile docker-compose.prod.yml deploy packages \
  | ssh -i "$VPS_SSH_KEY" -o BatchMode=yes "$VPS_HOST" "tar -xzf - -C $VPS_PATH"

echo "== build + up en el VPS =="
ssh -i "$VPS_SSH_KEY" -o BatchMode=yes "$VPS_HOST" \
  "cd $VPS_PATH && docker compose -f docker-compose.prod.yml up -d --build && docker compose -f docker-compose.prod.yml ps"
