# Security, Backup, Upgrade & HA

[← Manual Index](../MANUAL.md)

## 14. Security Hardening

1. **Secrets** — `.env` mode `600`; never commit; rotate passwords/tokens regularly.
2. **TLS** — Terminate TLS at reverse proxy; consider HSTS.
3. **Auth** — Grafana admin password strong; consider OAuth/LDAP for teams.
4. **Network** — Bind Prometheus/Alertmanager/Loki to localhost or private VLAN.
5. **Grafana** — Disable anonymous access; limit Editor role.
6. **Exporters** — Least privilege; firewall scrape ports.
7. **Updates** — Dependabot enabled; `docker compose pull` on a schedule.
8. **Audit** — Use dashboard 31 (Audit) and journal filters for sudo/auth.

See also [SECURITY.md](../../SECURITY.md).

---

## 15. Backup & Restore

### 15.1 Backup

```bash
./scripts/backup.sh
```

Typical contents: configuration (compose, prometheus, alertmanager, loki, grafana provisioning) and named volumes. Store archives **off-box**.

### 15.2 Restore

```bash
./scripts/restore.sh /path/to/backup-YYYYMMDD.tar.gz
```

1. Stop stack: `docker compose down`
2. Restore config + volumes per script
3. Start: `docker compose up -d`
4. Verify targets, Grafana login, recent metrics

### 15.3 Disaster recovery checklist

- [ ] Backup job scheduled and monitored
- [ ] Restore tested at least quarterly
- [ ] `.env` secrets recoverable from secure vault
- [ ] DNS / reverse proxy documented
- [ ] Runbooks accessible offline

---

## 16. Upgrade Procedure

```bash
cd /path/to/dashboardgravana-monitoring
git pull
docker compose pull
docker compose up -d
```

Read `CHANGELOG.md` before major version bumps. Prefer maintenance window for major upgrades. After upgrade: check `/targets`, Alertmanager status, Grafana datasource health.

---

## 17. Scaling & High Availability

| Stage | Approach |
|-------|----------|
| Single node | Default Compose stack |
| More targets | file_sd / HTTP SD; dedicated exporters |
| Long retention | Larger disk; remote_write to Thanos/Mimir |
| Multi-site | Prometheus federation; hierarchical Alertmanager |
| Logs at scale | Loki microservices + object storage (S3/MinIO) |
| Kubernetes | Helm charts (roadmap) |

Alertmanager is started with clustering-related flags so a second instance can join later.

---

[← Manual Index](../MANUAL.md)
