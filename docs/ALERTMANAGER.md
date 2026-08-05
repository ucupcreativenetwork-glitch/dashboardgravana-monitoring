# Alertmanager

> Manual: [manual/05-prometheus-alerting-logging.md](manual/05-prometheus-alerting-logging.md)

## Role

Prometheus evaluates rules → **Alertmanager** groups, inhibits, and routes to Discord / Telegram / Email.

Config: `alertmanager/alertmanager.yml`  
Templates: `alertmanager/templates/discord.tmpl`, `telegram.tmpl`

## Severity model

| Severity | Meaning |
|----------|---------|
| critical | Impact now — page / immediate |
| warning | Degraded or approaching limit |
| info | Informational |

Inhibition reduces noise (e.g. node down suppresses filesystem alerts on that node).

## UI

http://localhost:9093 — status, silences, alerts.

## Silences

Use the UI during maintenance. Always set **reason** and **expiry**.

## Rule files (Prometheus)

| File | Domain |
|------|--------|
| `prometheus/rules/infrastructure.yml` | Node, CPU, RAM, disk |
| `prometheus/rules/containers.yml` | Docker / cAdvisor |
| `prometheus/rules/application.yml` | Probes, SSL, stack |
| `prometheus/rules/proxmox.yml` | PVE |
| `prometheus/rules/services.yml` | Service checks |

## Notifications

- [DISCORD.md](DISCORD.md)
- Telegram / email via `.env` + receivers in `alertmanager.yml`

## Runbooks

- [runbooks/node-down.md](runbooks/node-down.md)
- [runbooks/filesystem-full.md](runbooks/filesystem-full.md)
- [runbooks/ssl-expiring.md](runbooks/ssl-expiring.md)
- [runbooks/ups-on-battery.md](runbooks/ups-on-battery.md)
