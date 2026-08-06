#!/usr/bin/env bash
# Offline + online smoke tests for DashboardGravana
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
FAIL=0
ok(){ printf '  OK   %s\n' "$*"; }
bad(){ printf '  FAIL %s\n' "$*"; FAIL=1; }
echo "=== smoke-test (static) ==="
command -v python3 >/dev/null && ok python3 || bad python3
python3 - <<'PY' || exit 1
import yaml, json, pathlib, sys
errs=[]
for f in [
  'docker-compose.yml','prometheus/prometheus.yml','prometheus/blackbox.yml',
  'alertmanager/alertmanager.yml','loki/loki-config.yml','promtail/promtail-config.yml',
  'grafana/provisioning/datasources/datasources.yml','grafana/provisioning/dashboards/dashboards.yml',
  'snmp-exporter/snmp.yml']:
  try: yaml.safe_load(open(f)); print('  OK  yaml', f)
  except Exception as e: print('  FAIL yaml', f, e); errs.append(f)
for f in pathlib.Path('prometheus/targets').glob('*.json'):
  try: json.load(open(f)); print('  OK  json', f.name)
  except Exception as e: print('  FAIL', f, e); errs.append(str(f))
n=0
for f in pathlib.Path('grafana/dashboards').rglob('*.json'):
  d=json.load(open(f)); n+=1
print(f'  OK  dashboards {n}')
c=yaml.safe_load(open('docker-compose.yml'))
for s in ['grafana','prometheus','alertmanager','loki','node-exporter','blackbox-exporter']:
  assert s in c['services'], s
print('  OK  compose core services')
sys.exit(1 if errs else 0)
PY
echo "=== smoke-test (docker compose config) ==="
if command -v docker >/dev/null 2>&1; then
  [[ -f .env ]] || { cp .env.example .env; sed -i 's/^GF_SECURITY_ADMIN_PASSWORD=.*/GF_SECURITY_ADMIN_PASSWORD=SmokeTest_ChangeMe_99!/' .env || true; }
  if docker compose --env-file .env config -q 2>/dev/null; then ok "docker compose config"; else bad "docker compose config"; fi
else
  printf '  SKIP docker not installed\n'
fi
echo "=== smoke-test (live endpoints) ==="
if command -v curl >/dev/null 2>&1; then
  for u in "http://127.0.0.1:9090/-/ready" "http://127.0.0.1:9093/-/ready" "http://127.0.0.1:3100/ready" "http://127.0.0.1:3000/api/health"; do
    if curl -sf --max-time 3 "$u" >/dev/null 2>&1; then ok "live $u"; else printf '  --   not up yet %s\n' "$u"; fi
  done
fi
echo "=== result ==="
if [[ "$FAIL" -eq 0 ]]; then echo "SMOKE STATIC CHECKS PASSED"; exit 0; fi
echo "SMOKE FAILED"; exit 1
