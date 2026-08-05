#!/usr/bin/env bash
# =============================================================================
# DashboardGravana — Installation script
# Supports Ubuntu 24.04, Debian 12, Proxmox VE hosts
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${ROOT_DIR}"

log()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
err()  { echo -e "\033[1;31m[ERR]\033[0m $*" >&2; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root (or with sudo) for Docker install and host mounts."
    exit 1
  fi
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-}"
  else
    OS_ID="unknown"
  fi
  log "Detected OS: ${OS_ID} ${OS_VERSION}"
}

install_docker() {
  if command -v docker &>/dev/null; then
    ok "Docker already installed: $(docker --version)"
    return
  fi
  log "Installing Docker Engine..."
  case "${OS_ID}" in
    ubuntu|debian|pop)
      apt-get update -qq
      apt-get install -y -qq ca-certificates curl gnupg
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/${OS_ID}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      chmod a+r /etc/apt/keyrings/docker.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS_ID} $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        > /etc/apt/sources.list.d/docker.list
      apt-get update -qq
      apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
      ;;
    *)
      err "Unsupported OS for automatic Docker install. Install Docker manually: https://docs.docker.com/engine/install/"
      exit 1
      ;;
  esac
  systemctl enable --now docker
  ok "Docker installed"
}

prepare_env() {
  if [[ ! -f .env ]]; then
    log "Creating .env from .env.example"
    cp .env.example .env
    warn "Edit .env and set GF_SECURITY_ADMIN_PASSWORD, DISCORD_WEBHOOK_URL, and other secrets before starting."
  else
    ok ".env already present"
  fi
}

create_dirs() {
  mkdir -p grafana/dashboards prometheus/rules prometheus/recording \
           alertmanager/templates loki promtail backup restore
  ok "Directory structure ready"
}

render_alertmanager() {
  if [[ -x "${ROOT_DIR}/scripts/render-alertmanager-config.sh" ]]; then
    log "Rendering Alertmanager config from template + .env"
    "${ROOT_DIR}/scripts/render-alertmanager-config.sh" || warn "Alertmanager render failed — using existing alertmanager.yml"
  fi
}

start_stack() {
  render_alertmanager
  log "Validating compose file..."
  docker compose config -q
  log "Pulling images..."
  docker compose pull
  log "Starting stack..."
  docker compose up -d
  ok "Stack started"
  log "Grafana:     http://localhost:${GRAFANA_PORT:-3000}"
  log "Prometheus:  http://localhost:${PROMETHEUS_PORT:-9090}"
  log "Alertmanager:http://localhost:${ALERTMANAGER_PORT:-9093}"
  log "Uptime Kuma: http://localhost:${UPTIME_KUMA_PORT:-3001}"
}

main() {
  require_root
  detect_os
  install_docker
  prepare_env
  create_dirs
  if [[ "${1:-}" == "--start" ]]; then
    start_stack
  else
    log "Run with --start to pull images and launch the stack after editing .env"
  fi
}

main "$@"
