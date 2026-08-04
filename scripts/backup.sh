#!/usr/bin/env bash
# Production backup of Grafana, Prometheus, Loki, Alertmanager, Uptime Kuma data
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_DIR="${ROOT_DIR}/backup"
STAMP=$(date +%Y%m%d-%H%M%S)
OUT="${BACKUP_DIR}/dg-backup-${STAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"
cd "${ROOT_DIR}"

echo "[INFO] Creating backup ${OUT}"
# Stop write-heavy services briefly for consistency (optional; comment out for live)
# docker compose stop prometheus loki grafana alertmanager uptime-kuma

docker compose exec -T prometheus kill -HUP 1 2>/dev/null || true

tar --exclude='backup' --exclude='*.tar.gz' -czf "${OUT}" \
  grafana/dashboards grafana/provisioning \
  prometheus/prometheus.yml prometheus/rules prometheus/recording \
  alertmanager \
  loki/loki-config.yml \
  promtail/promtail-config.yml \
  docker-compose.yml .env.example \
  2>/dev/null || true

# Volume data (requires root / docker)
VOLUMES=$(docker volume ls -q | grep -E 'dashboardgravana|grafana_data|prometheus_data|loki_data|alertmanager_data|uptime_kuma' || true)
if [[ -n "${VOLUMES}" ]]; then
  mkdir -p "${BACKUP_DIR}/volumes-${STAMP}"
  for v in ${VOLUMES}; do
    docker run --rm -v "${v}:/data:ro" -v "${BACKUP_DIR}/volumes-${STAMP}:/backup" alpine \
      tar czf "/backup/${v}.tar.gz" -C /data . || true
  done
  tar -czf "${BACKUP_DIR}/dg-volumes-${STAMP}.tar.gz" -C "${BACKUP_DIR}" "volumes-${STAMP}"
  rm -rf "${BACKUP_DIR}/volumes-${STAMP}"
fi

echo "[OK] Backup written: ${OUT}"
ls -lh "${BACKUP_DIR}"/dg-*${STAMP}* 2>/dev/null || true
