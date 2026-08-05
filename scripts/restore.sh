#!/usr/bin/env bash
# =============================================================================
# DashboardGravana — restore configuration from scripts/backup.sh archive
# Volume data restore: docs/BACKUP.md
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

log()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
err()  { echo -e "\033[1;31m[ERR]\033[0m $*" >&2; }

if [[ $# -lt 1 ]]; then
  err "Usage: $0 <dg-backup-YYYYMMDD-HHMMSS.tar.gz> [--yes]"
  exit 1
fi

ARCHIVE="$1"
YES=0
[[ "${2:-}" == "--yes" || "${2:-}" == "-y" ]] && YES=1

if [[ ! -f "${ARCHIVE}" ]]; then
  err "Archive not found: ${ARCHIVE}"
  exit 1
fi

cd "${ROOT_DIR}"

warn "This overwrites configuration files in ${ROOT_DIR}"
if [[ "${YES}" -ne 1 ]]; then
  read -r -p "Continue? [y/N] " ans
  [[ "${ans}" =~ ^[Yy]$ ]] || exit 0
fi

if docker compose ps -q 2>/dev/null | grep -q .; then
  warn "Stack appears running — recommended: docker compose down first"
fi

log "Extracting ${ARCHIVE}"
tar -xzf "${ARCHIVE}" -C "${ROOT_DIR}"

if [[ -x "${ROOT_DIR}/scripts/render-alertmanager-config.sh" && -f "${ROOT_DIR}/.env" ]]; then
  log "Re-rendering Alertmanager config from .env"
  "${ROOT_DIR}/scripts/render-alertmanager-config.sh" || warn "render failed — check .env"
fi

ok "Configuration restored"
log "Next: restore .env if needed → docker compose up -d → ./scripts/healthcheck.sh"
log "Volume restore: docs/BACKUP.md"
