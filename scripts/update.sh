#!/usr/bin/env bash
# DashboardGravana — safe stack update (git + images + recreate)
# Supports Ubuntu, Debian, Proxmox VE hosts with Docker Compose v2.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

log()  { printf '[update] %s\n' "$*"; }
die()  { printf '[update] ERROR: %s\n' "$*" >&2; exit 1; }

[[ -f docker-compose.yml ]] || die "run from repo root (docker-compose.yml missing)"
command -v docker >/dev/null 2>&1 || die "docker not found"
docker compose version >/dev/null 2>&1 || die "docker compose v2 plugin required"

SKIP_GIT=0
SKIP_PULL=0
YES=0
for arg in "$@"; do
  case "$arg" in
    --skip-git)  SKIP_GIT=1 ;;
    --skip-pull) SKIP_PULL=1 ;;
    -y|--yes)    YES=1 ;;
    -h|--help)
      cat <<'H'
Usage: ./scripts/update.sh [options]
  --skip-git   Do not git pull
  --skip-pull  Do not docker compose pull
  -y, --yes    Non-interactive
H
      exit 0
      ;;
  esac
done

if [[ "$YES" -ne 1 ]]; then
  read -r -p "Update DashboardGravana (git + images + recreate)? [y/N] " ans
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]] || { log "aborted"; exit 0; }
fi

if [[ "$SKIP_GIT" -eq 0 ]]; then
  if [[ -d .git ]]; then
    log "git pull..."
    git pull --ff-only || log "WARN: git pull failed (continue with local tree)"
  else
    log "no .git directory — skip git pull"
  fi
fi

if [[ "$SKIP_PULL" -eq 0 ]]; then
  log "docker compose pull..."
  docker compose pull
fi

log "recreate services..."
docker compose up -d --remove-orphans

log "waiting for health..."
sleep 5
docker compose ps

log "done. Check CHANGELOG.md for breaking changes after major bumps."
log "Verify: curl -s localhost:9090/-/ready && curl -s localhost:3000/api/health"
