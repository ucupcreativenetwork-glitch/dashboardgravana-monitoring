#!/usr/bin/env bash
# =============================================================================
# DashboardGravana — production backup (configs + Docker volumes)
# Supports: Ubuntu, Debian, Proxmox VE hosts
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_DIR="${DG_BACKUP_DIR:-${ROOT_DIR}/backup}"
KEEP="${DG_BACKUP_KEEP:-14}"
QUIESCE="${DG_BACKUP_QUIESCE:-0}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_CFG="${BACKUP_DIR}/dg-backup-${STAMP}.tar.gz"
OUT_VOL="${BACKUP_DIR}/dg-volumes-${STAMP}.tar.gz"

log()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }

mkdir -p "${BACKUP_DIR}"
cd "${ROOT_DIR}"

if [[ "${QUIESCE}" == "1" ]]; then
  log "Quiescing writers (DG_BACKUP_QUIESCE=1)"
  docker compose stop prometheus loki grafana alertmanager uptime-kuma 2>/dev/null || true
fi

docker compose exec -T prometheus kill -HUP 1 2>/dev/null || true

log "Archiving configuration → ${OUT_CFG}"
tar -czf "${OUT_CFG}" \
  grafana/dashboards \
  grafana/provisioning \
  prometheus/prometheus.yml \
  prometheus/rules \
  prometheus/recording \
  prometheus/targets \
  prometheus/blackbox.yml \
  alertmanager \
  loki/loki-config.yml \
  promtail/promtail-config.yml \
  pve-exporter/pve.yml.example \
  docker-compose.yml \
  .env.example \
  .yamllint.yml \
  scripts \
  docs \
  2>/dev/null

ok "Config archive: ${OUT_CFG}"

if command -v docker >/dev/null 2>&1; then
  mapfile -t VOLUMES < <(docker volume ls -q | grep -E 'grafana_data|prometheus_data|loki_data|alertmanager_data|uptime_kuma' || true)
  if [[ ${#VOLUMES[@]} -gt 0 ]]; then
    VOL_TMP="${BACKUP_DIR}/volumes-${STAMP}"
    mkdir -p "${VOL_TMP}"
    for v in "${VOLUMES[@]}"; do
      log "Volume snapshot: ${v}"
      safe_name="$(echo "${v}" | tr '/' '_')"
      docker run --rm \
        -v "${v}:/data:ro" \
        -v "${VOL_TMP}:/backup" \
        alpine:3.20 \
        tar czf "/backup/${safe_name}.tar.gz" -C /data . \
        || warn "Failed snapshot ${v}"
    done
    tar -czf "${OUT_VOL}" -C "${BACKUP_DIR}" "volumes-${STAMP}"
    rm -rf "${VOL_TMP}"
    ok "Volumes archive: ${OUT_VOL}"
  else
    warn "No matching Docker volumes found — config-only backup"
  fi
else
  warn "docker not available — config-only backup"
fi

if [[ "${QUIESCE}" == "1" ]]; then
  log "Restarting stack after quiesce"
  docker compose up -d 2>/dev/null || true
fi

log "Retention: keeping last ${KEEP} config archives"
mapfile -t OLD < <(ls -1t "${BACKUP_DIR}"/dg-backup-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)) || true)
for f in "${OLD[@]:-}"; do
  [[ -n "${f}" ]] || continue
  rm -f "${f}"
done
mapfile -t OLDV < <(ls -1t "${BACKUP_DIR}"/dg-volumes-*.tar.gz 2>/dev/null | tail -n +$((KEEP + 1)) || true)
for f in "${OLDV[@]:-}"; do
  [[ -n "${f}" ]] || continue
  rm -f "${f}"
done

ok "Backup complete"
ls -lh "${BACKUP_DIR}"/dg-*${STAMP}* 2>/dev/null || true
