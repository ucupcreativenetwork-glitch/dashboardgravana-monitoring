# Backup & Restore

Production backup of configuration **and** Docker volumes for DashboardGravana.

## What is backed up

| Component | Config | Volume data |
|-----------|--------|-------------|
| Grafana | dashboards, provisioning | `grafana_data` |
| Prometheus | prometheus.yml, rules, recording, targets | `prometheus_data` |
| Alertmanager | yml + templates | `alertmanager_data` |
| Loki | loki-config.yml | `loki_data` |
| Uptime Kuma | — | `uptime_kuma_data` |
| Stack | compose, .env.example | — |

Never commit `.env` or live `pve.yml` to git; keep secrets in encrypted off-host backups only.

## Backup

```bash
sudo ./scripts/backup.sh
```

Outputs:

```
backup/dg-backup-YYYYMMDD-HHMMSS.tar.gz
backup/dg-volumes-YYYYMMDD-HHMMSS.tar.gz
```

| Variable | Default | Meaning |
|----------|---------|---------|
| `DG_BACKUP_DIR` | `./backup` | Output directory |
| `DG_BACKUP_KEEP` | `14` | Archives to retain |
| `DG_BACKUP_QUIESCE` | `0` | `1` = stop writers briefly |

### Cron

```bash
15 2 * * * cd /opt/dashboardgravana-monitoring && ./scripts/backup.sh >> /var/log/dg-backup.log 2>&1
```

## Restore — configuration

```bash
docker compose down
./scripts/restore.sh backup/dg-backup-YYYYMMDD-HHMMSS.tar.gz
./scripts/render-alertmanager-config.sh
docker compose up -d
./scripts/healthcheck.sh
```

## Restore — volumes

See destructive volume example in this doc’s full version in-repo; adjust volume names via `docker volume ls`.

## Disaster recovery order

1. Rebuild host + Docker
2. Clone repo at known-good tag
3. Restore `.env` from secret store
4. Restore config archive
5. Render Alertmanager
6. Restore volumes if needed
7. `docker compose up -d`
8. Healthcheck + test alert

## Related

- `scripts/backup.sh` · `scripts/restore.sh`
- [INSTALL.md](INSTALL.md) · [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
