#!/usr/bin/env bash
# =============================================================================
# Render Alertmanager config from template using values in .env
# Alertmanager does NOT expand ${ENV} itself — this step is required.
#
# Usage:
#   ./scripts/render-alertmanager-config.sh
#   # then: docker compose up -d alertmanager
#
# Supported on: Ubuntu, Debian, Proxmox (requires gettext-base / envsubst)
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

TMPL="${ROOT_DIR}/alertmanager/alertmanager.yml.tmpl"
OUT="${ROOT_DIR}/alertmanager/alertmanager.yml"
ENV_FILE="${ROOT_DIR}/.env"

log()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
err()  { echo -e "\033[1;31m[ERR]\033[0m $*" >&2; }

if [[ ! -f "${TMPL}" ]]; then
  err "Template not found: ${TMPL}"
  exit 1
fi

if ! command -v envsubst &>/dev/null; then
  warn "envsubst not found — installing gettext-base (Ubuntu/Debian/Proxmox)"
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq gettext-base
  else
    err "Install gettext (envsubst) manually, then re-run."
    exit 1
  fi
fi

export DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL:-https://discord.com/api/webhooks/CHANGE_ME/CHANGE_ME}"
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-0000000000:CHANGE_ME_TELEGRAM_BOT_TOKEN}"
export TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID:-0}"
export ALERTMANAGER_SMTP_SMARTHOST="${ALERTMANAGER_SMTP_SMARTHOST:-smtp.example.com:587}"
export ALERTMANAGER_SMTP_FROM="${ALERTMANAGER_SMTP_FROM:-alertmanager@example.com}"
export ALERTMANAGER_SMTP_AUTH_USERNAME="${ALERTMANAGER_SMTP_AUTH_USERNAME:-}"
export ALERTMANAGER_SMTP_AUTH_PASSWORD="${ALERTMANAGER_SMTP_AUTH_PASSWORD:-}"
export ALERTMANAGER_SMTP_REQUIRE_TLS="${ALERTMANAGER_SMTP_REQUIRE_TLS:-true}"
export ALERTMANAGER_EMAIL_TO="${ALERTMANAGER_EMAIL_TO:-oncall@example.com}"

if [[ -f "${ENV_FILE}" ]]; then
  log "Loading ${ENV_FILE}"
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
else
  warn ".env not found — using defaults / current environment"
fi

: "${DISCORD_WEBHOOK_URL:=https://discord.com/api/webhooks/CHANGE_ME/CHANGE_ME}"
: "${TELEGRAM_BOT_TOKEN:=0000000000:CHANGE_ME_TELEGRAM_BOT_TOKEN}"
: "${TELEGRAM_CHAT_ID:=0}"
: "${ALERTMANAGER_SMTP_SMARTHOST:=smtp.example.com:587}"
: "${ALERTMANAGER_SMTP_FROM:=alertmanager@example.com}"
: "${ALERTMANAGER_SMTP_AUTH_USERNAME:=}"
: "${ALERTMANAGER_SMTP_AUTH_PASSWORD:=}"
: "${ALERTMANAGER_SMTP_REQUIRE_TLS:=true}"
: "${ALERTMANAGER_EMAIL_TO:=oncall@example.com}"

export DISCORD_WEBHOOK_URL TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID
export ALERTMANAGER_SMTP_SMARTHOST ALERTMANAGER_SMTP_FROM
export ALERTMANAGER_SMTP_AUTH_USERNAME ALERTMANAGER_SMTP_AUTH_PASSWORD
export ALERTMANAGER_SMTP_REQUIRE_TLS ALERTMANAGER_EMAIL_TO

VARS='${DISCORD_WEBHOOK_URL} ${TELEGRAM_BOT_TOKEN} ${TELEGRAM_CHAT_ID} ${ALERTMANAGER_SMTP_SMARTHOST} ${ALERTMANAGER_SMTP_FROM} ${ALERTMANAGER_SMTP_AUTH_USERNAME} ${ALERTMANAGER_SMTP_AUTH_PASSWORD} ${ALERTMANAGER_SMTP_REQUIRE_TLS} ${ALERTMANAGER_EMAIL_TO}'

envsubst "${VARS}" < "${TMPL}" > "${OUT}"

if grep -q '\${' "${OUT}"; then
  warn "Some \${VAR} placeholders remain in ${OUT} — check template vs envsubst list"
fi

ok "Rendered ${OUT}"
log "Restart Alertmanager to apply: docker compose up -d alertmanager"
