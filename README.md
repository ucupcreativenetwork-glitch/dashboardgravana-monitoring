# DashboardGravana Monitoring

**Production-grade, fully self-hosted Open Source Monitoring Stack** for HomeLab, SMB, Enterprise and Datacenter.

Similar in capability to Datadog, Zabbix, PRTG, Grafana Cloud, Prometheus Operator and Elastic Observability — without vendor lock-in.

---

## Architecture

```
                    ┌─────────────────────────────────────────────────┐
                    │              Reverse Proxy (TLS)                │
                    │         Nginx / Traefik / Caddy / CF            │
                    └────────────┬───────────────┬────────────────────┘
                                 │               │
              ┌──────────────────▼───┐     ┌─────▼──────────────────┐
              │      Grafana         │     │     Uptime Kuma        │
              │  Dashboards / UI     │     │  Synthetic / Status    │
              └──────────┬───────────┘     └────────────────────────┘
                         │
         ┌───────────────┼───────────────────────────────┐
         │               │                               │
┌────────▼──────┐ ┌──────▼──────┐ ┌──────────▼──────────┐
│  Prometheus   │ │ Alertmanager│ │        Loki         │
│  Metrics TSDB │ │  Routing    │ │   Log aggregation   │
└───────┬───────┘ └──────┬──────┘ └──────────▲──────────┘
        │                │                   │
        │         Discord / Telegram / Email │
        │                                    │
┌───────▼────────────────────────────────────┴──────────┐
│  Exporters & Agents                                    │
│  node-exporter · cAdvisor · blackbox · pve-exporter    │
│  Promtail (Docker / journal / syslog / nginx)          │
│  MySQL / Redis / Nextcloud / custom exporters          │
└────────────────────────────────────────────────────────┘
        │
┌───────▼────────────────────────────────────────────────┐
│  Targets: Linux · Windows · Docker · Proxmox · VMs     │
│  LXC · NAS · UPS · pfSense · Mikrotik · Cloudflare     │
│  Nextcloud · Immich · Shinobi · MariaDB · Redis        │
└────────────────────────────────────────────────────────┘
```

### Design decisions

| Decision | Rationale |
|----------|-----------|
| Docker Compose first | Fastest path to production for HomeLab/SMB; clear path to K8s (Helm later) |
| Single Prometheus | Simple ops; federation + remote_write ready for multi-node / HA |
| Loki single-binary | Sufficient for most sites; migrate to microservices when needed |
| Alertmanager clustering prepared | `--cluster.listen-address` already set |
| Recording rules | Keep dashboards fast and reduce query load |
| Severity + inhibition | Reduce alert noise in production |
| Secrets via `.env` | Simple; migrate to Vault / Docker secrets for multi-tenant |
| Resource limits | Protect the monitoring host itself |
| Healthchecks | Compose restarts only unhealthy containers |

---

## Requirements

- Ubuntu Server 24.04 LTS (recommended), Debian 12, or Proxmox VE host
- Docker Engine 24+ and Docker Compose v2 plugin
- Minimum 4 CPU / 8 GB RAM / 50 GB SSD for a small environment
- Recommended 8+ CPU / 16–32 GB RAM / 200+ GB for medium–large
- Outbound HTTPS for Discord / Telegram / image pulls
- (Optional) SMTP for email alerts

---

## Quick Start

```bash
git clone https://github.com/ucupcreativenetwork-glitch/dashboardgravana-monitoring.git
cd dashboardgravana-monitoring

# One-shot install (Docker + env + directories)
sudo ./scripts/install.sh

# Edit secrets
cp .env.example .env
nano .env   # set GF_SECURITY_ADMIN_PASSWORD, DISCORD_WEBHOOK_URL, etc.

# Launch
sudo ./scripts/install.sh --start
# or
docker compose up -d
```

Access:

| Service       | Default URL                  |
|---------------|------------------------------|
| Grafana       | http://localhost:3000        |
| Prometheus    | http://localhost:9090        |
| Alertmanager  | http://localhost:9093        |
| Uptime Kuma   | http://localhost:3001        |
| Loki          | http://localhost:3100        |

Default Grafana credentials come from `.env` (`GF_SECURITY_ADMIN_USER` / `GF_SECURITY_ADMIN_PASSWORD`).

---

## Configuration

### Environment

All runtime configuration is driven by `.env`. See `.env.example` for the full list and comments.

Critical variables:

- `GF_SECURITY_ADMIN_PASSWORD` — **required**
- `DISCORD_WEBHOOK_URL` — primary notification channel
- `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHAT_ID` — optional
- `PROMETHEUS_RETENTION_TIME` / `PROMETHEUS_RETENTION_SIZE`
- `PVE_*` — when enabling Proxmox exporter

### Adding scrape targets

Edit `prometheus/prometheus.yml` or (preferred for multi-node) enable `file_sd_configs` and drop JSON files under `prometheus/targets/`.

Example `prometheus/targets/nodes.json`:

```json
[
  {
    "targets": ["192.168.1.10:9100", "192.168.1.11:9100"],
    "labels": { "env": "prod", "role": "compute" }
  }
]
```

### Enabling Proxmox monitoring

1. Create a dedicated Proxmox user / API token with PVEAuditor (or minimal monitoring rights).
2. Uncomment the `pve-exporter` service in `docker-compose.yml`.
3. Create `pve-exporter/pve.yml` and set `PVE_*` in `.env`.
4. Uncomment the `pve` job in `prometheus/prometheus.yml`.

### Dashboards

Dashboards live under `grafana/dashboards/` and are auto-provisioned.

Current ship list (expanding):

| #  | Dashboard              | UID                     |
|----|------------------------|-------------------------|
| 01 | Executive Overview     | dg-executive-overview   |
| 02 | Infrastructure Overview| (planned)               |
| 03 | Linux Overview         | (planned)               |
| …  | …                      | …                       |
| 20 | Alert Center           | (planned)               |
| 30 | Logs                   | (planned)               |

All dashboards use dark theme, variables, thresholds and navigation links.

### Alerts

Rules are split by domain:

- `prometheus/rules/infrastructure.yml` — node, CPU, RAM, disk, filesystem
- `prometheus/rules/containers.yml` — Docker / cAdvisor
- `prometheus/rules/application.yml` — probes, SSL, stack health

Alertmanager routes by `severity` and `team`, with inhibition to suppress noise.

---

## Backup & Restore

```bash
./scripts/backup.sh          # config + volume snapshots
./scripts/restore.sh <archive.tar.gz>
```

Store backups off-box. Test restore periodically (disaster recovery).

---

## Security

See [SECURITY.md](SECURITY.md).

Summary:

- Never commit `.env`
- TLS at the edge (reverse proxy)
- Disable anonymous Grafana access
- Least-privilege exporter credentials
- Keep images patched (Dependabot enabled)

---

## Scaling & HA

| Stage        | Approach                                      |
|--------------|-----------------------------------------------|
| Single node  | Current Compose stack                         |
| Multi-node   | Federation + file_sd / HTTP SD                |
| Long-term    | remote_write → Thanos / Mimir / Grafana Cloud |
| Logs scale   | Loki distributed (object storage)             |
| K8s          | Migrate to Helm charts (roadmap)              |

Alertmanager is already started with clustering flags.

---

## Upgrade

```bash
git pull
docker compose pull
docker compose up -d
```

Check CHANGELOG.md for breaking changes. Prefer blue/green or maintenance windows for major Prometheus / Grafana major versions.

---

## Troubleshooting

| Symptom                    | Check                                      |
|----------------------------|--------------------------------------------|
| Grafana empty dashboards   | Prometheus targets up? Recording rules?    |
| No alerts in Discord       | `DISCORD_WEBHOOK_URL`, Alertmanager logs   |
| Node metrics missing       | node-exporter reachable, firewall          |
| High disk use              | Retention settings, Loki retention         |
| cAdvisor permission errors | Privileged + host mounts (documented)      |

```bash
docker compose logs -f grafana prometheus alertmanager loki
docker compose ps
curl -s localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, health}'
```

---

## Roadmap

- [ ] Full set of 35 enterprise dashboards
- [ ] PVE / Mikrotik / pfSense / UPS exporters fully wired
- [ ] Nextcloud, Immich, Shinobi, MariaDB, Redis dashboards + alerts
- [ ] Cloudflare analytics exporter
- [ ] SMART / temperature panels
- [ ] Helm chart + Kubernetes manifests
- [ ] Thanos / Mimir optional profile
- [ ] Ansible / Terraform deployment modules

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). PRs that add production-ready dashboards, exporters or runbooks are especially welcome.

---

## License

MIT — see [LICENSE](LICENSE).

---

## Maintainers

- [@ucupcreativenetwork-glitch](https://github.com/ucupcreativenetwork-glitch)

---

**DashboardGravana** — Own your observability.
