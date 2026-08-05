#!/usr/bin/env bash
# DashboardGravana — stop stack and optionally remove volumes / images
# DANGER: --purge deletes monitoring data volumes.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

log() { printf '[uninstall] %s\n' "$*"; }
die() { printf '[uninstall] ERROR: %s\n' "$*" >&2; exit 1; }

PURGE=0
YES=0
for arg in "$@"; do
  case "$arg" in
    --purge) PURGE=1 ;;
    -y|--yes) YES=1 ;;
    -h|--help)
      cat <<'H'
Usage: ./scripts/uninstall.sh [options]
  --purge   Also docker compose down -v (DELETE volumes / data)
  -y, --yes Non-interactive confirm
H
      exit 0
      ;;
  esac
done

[[ -f docker-compose.yml ]] || die "docker-compose.yml not found"

if [[ "$YES" -ne 1 ]]; then
  if [[ "$PURGE" -eq 1 ]]; then
    read -r -p "STOP stack AND DELETE volumes (metrics/logs/grafana DB)? Type DELETE to confirm: " ans
    [[ "$ans" == "DELETE" ]] || { log "aborted"; exit 0; }
  else
    read -r -p "Stop DashboardGravana containers (volumes kept)? [y/N] " ans
    [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]] || { log "aborted"; exit 0; }
  fi
fi

if [[ "$PURGE" -eq 1 ]]; then
  log "docker compose down -v --remove-orphans"
  docker compose down -v --remove-orphans
  log "volumes removed. Config files in $ROOT are kept."
else
  log "docker compose down --remove-orphans"
  docker compose down --remove-orphans
  log "volumes retained. Use --purge to delete data volumes."
fi

log "done."
