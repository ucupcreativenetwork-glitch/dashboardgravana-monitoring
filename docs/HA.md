# High Availability

- **Default:** single-node Compose + `./scripts/backup.sh`
- **Alertmanager pair:** `alertmanager/ha/`
- **Long retention:** [REMOTE-WRITE.md](REMOTE-WRITE.md)
- **Grafana multi-replica:** external DB (`GF_DATABASE_*`), not SQLite
