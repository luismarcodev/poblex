#!/usr/bin/env bash
# Bootstrap de Poblex en un VPS que YA tiene Docker/ufw/fail2ban instalados
# (mismo VPS que Business Manager). No repite esa instalación: solo crea la
# carpeta de la app y abre los puertos propios de Poblex en el firewall.
# Ejecutar UNA vez como el usuario con acceso a Docker (con sudo) en el VPS.
set -euo pipefail

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker no está instalado. Este script asume que ya se ejecutó el" >&2
  echo "bootstrap de Business Manager en este VPS. Instálalo antes de seguir." >&2
  exit 1
fi

echo "== Carpeta de la app =="
sudo mkdir -p /opt/poblex
sudo chown "$USER":"$USER" /opt/poblex

echo "== Firewall: puertos propios de Poblex =="
sudo ufw allow 8090/tcp
sudo ufw allow 8091/tcp

echo "== Listo. Clona el repo en /opt/poblex y ejecuta gen-env.sh. =="
