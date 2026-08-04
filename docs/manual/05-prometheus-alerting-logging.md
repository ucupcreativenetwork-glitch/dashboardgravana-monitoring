# Prometheus, Alerting & Logging

[← Manual Index](../MANUAL.md)

## 8. Prometheus Configuration

### 8.1 Main config

File: `prometheus/prometheus.yml`

- Global scrape/evaluation intervals
- Rule files under `prometheus/rules/` and `prometheus/recording/`
- Alertmanager target
- Scrape jobs: prometheus, node-exporter, cadvisor, blackbox, loki, grafana, alertmanager, (optional) pve

### 8.2 Adding node targets (recommended)

Prefer **file service discovery** for many hosts.

Create `prometheus/targets/nodes.json`:

```json
[
  {
    "targets": ["192.168.1.10:9100", "192.168.1.11:9100"],
    "labels": {
      "env": "prod",
      "role": "compute",
      "site": "dc1"
    }
  }
]
```

Ensure `prometheus.yml` includes a job with `file_sd_configs` pointing at that directory (reload Prometheus after changes).

Reload without downtime:

```bash
curl -X POST http://localhost:9090/-/reload
# or
docker compose kill -s SIGHUP prometheus
```

### 8.3 Recording rules

File: `prometheus/recording/node.yml`

Pre-aggregations such as:

- `instance:node_cpu_utilisation:rate5m`
- `instance:node_memory_utilisation:ratio`
- `instance:node_network_receive_bytes:rate5m`
- `instance:node_filesystem_avail:ratio`

Dashboards query these for performance and consistency.

### 8.4 Alert rules

| File | Domain |
|------|--------|
| `prometheus/rules/infrastructure.yml` | Node down, CPU, RAM, disk, filesystem |
| `prometheus/rules/containers.yml` | OOM, container CPU/memory |
| `prometheus/rules/application.yml` | Probe fail, SSL expiry, stack health |
| `prometheus/rules/proxmox.yml` | PVE node/guest/storage |
| `prometheus/rules/services.yml` | Service-level checks |

---

## 9. Alerting

### 9.1 Flow

```
Prometheus evaluates rules
        ↓
Firing alerts → Alertmanager
        ↓
Grouping / inhibition / routing
        ↓
Discord / Telegram / Email
```

### 9.2 Severity model

| Severity | Meaning | Typical action |
|----------|---------|----------------|
| `critical` | Service impact now | Page / immediate response |
| `warning` | Degraded or approaching limit | Ticket / next business hours |
| `info` | Informational | Log / optional channel |

Inhibition rules suppress lower severities when a higher parent alert is active (e.g. node down suppresses filesystem alerts on that node).

### 9.3 Silences

Use Alertmanager UI (`:9093`) or API to silence during maintenance. Document every silence with reason and expiry.

### 9.4 Runbooks

| Alert theme | Runbook |
|-------------|---------|
| Node down | [docs/runbooks/node-down.md](runbooks/node-down.md) |
| Filesystem full | [docs/runbooks/filesystem-full.md](runbooks/filesystem-full.md) |
| SSL expiring | [docs/runbooks/ssl-expiring.md](runbooks/ssl-expiring.md) |
| UPS on battery | [docs/runbooks/ups-on-battery.md](runbooks/ups-on-battery.md) |

Link runbook URLs in alert annotations where possible.

---

## 10. Logging (Loki + Promtail)

### 10.1 Loki

Config: `loki/loki-config.yml`

- Single-binary mode suitable for HomeLab/SMB
- Retention controlled via compactor / limits (tune for disk)
- Query from Grafana Explore with LogQL

### 10.2 Promtail

Config: `promtail/promtail-config.yml`

Typical sources: Docker container logs, systemd journal, application log files.

Labels should stay low-cardinality (job, host, unit, container name — not unbounded request IDs as labels).

### 10.3 Example LogQL

```logql
{job="systemd-journal"} |= "sudo"
{job="docker"} |= "error"
{job="systemd-journal"} |~ "(?i)fail|error|panic"
```

---

[← Manual Index](../MANUAL.md)
