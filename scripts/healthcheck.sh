#!/usr/bin/env bash
# DashboardGravana — host + stack health summary
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
ok()   { printf '  OK   %s\n' "$*"; }
bad()  { printf '  FAIL %s\n' "$*"; FAIL=1; }
info() { printf '  --   %s\n' "$*"; }
printf '=== DashboardGravana healthcheck ===\n'
printf 'host: %s  time: %s\n' "$(hostname -f 2>/dev/null || hostname)" "$(date -Is)"
if command -v docker >/dev/null 2>&1; then
  ok "docker available"
  docker compose version >/dev/null 2>&1 && ok "docker compose v2" || bad "docker compose v2 missing"
else
  bad "docker not found"
fi
[[ -f docker-compose.yml ]] && { printf '\n--- containers ---\n'; docker compose ps 2>/dev/null || true; }
check_http() {
  local name="$1" url="$2"
  if curl -sf --max-time 5 "$url" >/dev/null 2>&1; then ok "$name ($url)"; else bad "$name ($url)"; fi
}
printf '\n--- endpoints (critical) ---\n'
check_http "Prometheus ready"   "http://127.0.0.1:${PROMETHEUS_PORT:-9090}/-/ready"
check_http "Alertmanager ready" "http://127.0.0.1:${ALERTMANAGER_PORT:-9093}/-/ready"
check_http "Loki ready"         "http://127.0.0.1:${LOKI_PORT:-3100}/ready"
check_http "Grafana health"     "http://127.0.0.1:${GRAFANA_PORT:-3000}/api/health"
printf '\n--- endpoints (optional) ---\n'
curl -sf --max-time 3 "http://127.0.0.1:${UPTIME_KUMA_PORT:-3001}" >/dev/null 2>&1 && ok "Uptime Kuma" || info "Uptime Kuma not responding"
curl -sf --max-time 3 "http://127.0.0.1:${NODE_EXPORTER_PORT:-9100}/metrics" >/dev/null 2>&1 && ok "Node exporter" || info "Node exporter not on localhost"
curl -sf --max-time 3 "http://127.0.0.1:${BLACKBOX_EXPORTER_PORT:-9115}/metrics" >/dev/null 2>&1 && ok "Blackbox exporter" || info "Blackbox not responding"
curl -sf --max-time 3 "http://127.0.0.1:${PVE_EXPORTER_PORT:-9221}/metrics" >/dev/null 2>&1 && ok "PVE exporter" || info "PVE exporter not running"
printf '\n--- prometheus targets sample ---\n'
if command -v jq >/dev/null 2>&1 && curl -sf --max-time 5 "http://127.0.0.1:${PROMETHEUS_PORT:-9090}/api/v1/targets" >/dev/null; then
  curl -s "http://127.0.0.1:${PROMETHEUS_PORT:-9090}/api/v1/targets" | jq -r '.data.activeTargets[] | "\(.labels.job)\t\(.health)"' 2>/dev/null | sort -u | head -30 || true
else
  info "jq or Prometheus API unavailable for target list"
fi
printf '\n--- disk / memory ---\n'
df -h / 2>/dev/null | tail -1 | awk '{print "  root: "$5" used ("$3"/"$2")"}' || true
command -v free >/dev/null && free -h | awk 'NR==2{print "  mem: total="$2" used="$3" avail="$7}' || true
printf '\n=== result ===\n'
if [[ "$FAIL" -eq 0 ]]; then printf 'ALL CRITICAL CHECKS PASSED\n'; exit 0; else printf 'ONE OR MORE CRITICAL CHECKS FAILED\n'; exit 1; fi
