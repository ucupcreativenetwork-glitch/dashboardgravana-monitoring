#!/usr/bin/env bash
# DashboardGravana — host + stack health summary
# Exit 0 if core services are ready; non-zero if any critical check fails.
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

if [[ -f docker-compose.yml ]]; then
  printf '\n--- containers ---\n'
  docker compose ps || true
fi

check_http() {
  local name="$1" url="$2"
  if curl -sf --max-time 5 "$url" >/dev/null 2>&1; then
    ok "$name ($url)"
  else
    bad "$name ($url)"
  fi
}

printf '\n--- endpoints ---\n'
check_http "Prometheus ready"   "http://127.0.0.1:9090/-/ready"
check_http "Alertmanager ready" "http://127.0.0.1:9093/-/ready"
check_http "Loki ready"         "http://127.0.0.1:3100/ready"
check_http "Grafana health"     "http://127.0.0.1:3000/api/health"

if curl -sf --max-time 3 "http://127.0.0.1:3001" >/dev/null 2>&1; then
  ok "Uptime Kuma (http://127.0.0.1:3001)"
else
  info "Uptime Kuma not responding (optional)"
fi

printf '\n--- disk ---\n'
df -h / | tail -1 | awk '{print "  root filesystem: "$5" used ("$3"/"$2")"}'

printf '\n--- memory ---\n'
if command -v free >/dev/null 2>&1; then
  free -h | awk 'NR==2{print "  mem: total="$2" used="$3" avail="$7}'
fi

printf '\n=== result ===\n'
if [[ "$FAIL" -eq 0 ]]; then
  printf 'ALL CRITICAL CHECKS PASSED\n'
  exit 0
else
  printf 'ONE OR MORE CRITICAL CHECKS FAILED\n'
  exit 1
fi
