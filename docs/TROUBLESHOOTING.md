# Troubleshooting

> Manual: [manual/08-operations-faq.md](manual/08-operations-faq.md)

## Quick checks

```bash
./scripts/healthcheck.sh
docker compose ps
docker compose logs -f grafana prometheus alertmanager loki promtail
```

```bash
curl -s localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, instance, health}'
curl -s localhost:9090/api/v1/rules | jq '.data.groups[].name'
curl -s localhost:9093/api/v2/status
```

## Symptom matrix

| Symptom | Check |
|---------|--------|
| Empty Grafana panels | Prometheus up? Targets healthy? Recording rules? Time range / variables? |
| No Discord alerts | `DISCORD_WEBHOOK_URL`, Alertmanager config/logs, inhibition, silences |
| Missing node metrics | node-exporter, firewall to :9100, scrape job labels |
| High disk usage | `PROMETHEUS_RETENTION_*`, Loki retention, unused Docker images |
| cAdvisor errors | Privileged mode, host mounts (see compose comments) |
| Proxmox metrics missing | Token rights, `pve.yml`, scrape job enabled, API TLS |
| SSL panels empty | Blackbox HTTPS modules + probe targets configured |

## Datasources

If panels show “datasource not found”, confirm provisioning UIDs **Prometheus** and **Loki** in:

`grafana/provisioning/datasources/datasources.yml`

## Update / rollback

```bash
./scripts/update.sh
# rollback: pin image tags in docker-compose.yml, then
docker compose up -d
```

## Still stuck?

1. Open a Question or Bug report on GitHub  
2. Attach redacted `docker compose ps` and target health output (no secrets)
