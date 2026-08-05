# Loki & Promtail (Logs)

> Manual: [manual/05-prometheus-alerting-logging.md](manual/05-prometheus-alerting-logging.md)

## Components

| Component | Role | Config |
|-----------|------|--------|
| **Loki** | Log store + LogQL API | `loki/loki-config.yml` |
| **Promtail** | Ship journal / Docker / files | `promtail/promtail-config.yml` |

Grafana datasource UID: **Loki** (provisioned).

## Query in Grafana

**Explore → Loki**, examples:

```logql
{job="systemd-journal"} |= "sudo"
{job="docker"} |= "error"
{job="systemd-journal"} |~ "(?i)fail|error|panic"
```

Dashboards: **30 Logs** (`dg-logs`), **31 Audit** (`dg-audit`).

## Retention & disk

Tune retention/limits in `loki/loki-config.yml` before disks fill. Monitor host disk via Capacity / Infrastructure dashboards.

## Labels

Keep cardinality low: `job`, `host`, `unit`, container name — **not** unbounded request IDs as labels.

## Verify

```bash
curl -s http://localhost:3100/ready
docker compose logs -f loki promtail
```
