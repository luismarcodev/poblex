#!/usr/bin/env bash
# Despliega/actualiza la app en el VPS: pull del repo, build de imágenes,
# migraciones de Prisma (las lanza el propio contenedor api al arrancar) y
# levantar servicios. Ejecutar dentro de /opt/poblex en el VPS.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "== git pull =="
git pull --ff-only

echo "== docker compose build =="
docker compose -f docker-compose.prod.yml build

echo "== docker compose up =="
docker compose -f docker-compose.prod.yml up -d

echo "== Estado =="
docker compose -f docker-compose.prod.yml ps
