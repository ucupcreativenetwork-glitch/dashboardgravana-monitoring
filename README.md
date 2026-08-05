# DashboardGravana Monitoring

**Production-grade, fully self-hosted Open Source Monitoring Stack** for HomeLab, SMB, Enterprise and Datacenter.

Similar in capability to Datadog, Zabbix, PRTG, Grafana Cloud, Prometheus Operator and Elastic Observability — without vendor lock-in.

---

## Documentation

- **[Manual Book](docs/MANUAL.md)** — full installation, configuration, operations, FAQ
- [Architecture](docs/ARCHITECTURE.md)
- [Install](docs/INSTALL.md) · [Reverse Proxy & TLS](docs/REVERSE-PROXY.md) · [Backup & DR](docs/BACKUP.md)
- [Proxmox](docs/PROXMOX.md) · [Blackbox](docs/BLACKBOX.md) · [Alertmanager](docs/ALERTMANAGER.md) · [Telegram](docs/TELEGRAM.md) · [Discord](docs/DISCORD.md)
- [Runbooks](docs/runbooks/) · [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Roadmap](ROADMAP.md) · [Changelog](CHANGELOG.md)

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
│  Exporters: node · cAdvisor · blackbox · pve · Promtail│
└────────────────────────────────────────────────────────┘
```

### Design decisions

| Decision | Rationale |
|----------|-----------|
| Docker Compose first | Fastest path to production; clear path to K8s later |
| Single Prometheus | Simple ops; federation + remote_write ready |
| Loki single-binary | Sufficient for most sites |
| Alertmanager clustering prepared | HA-ready flags |
| Recording rules | Fast dashboards, lower query load |
| file_sd targets | Multi-node without editing prometheus.yml |
| Secrets via `.env` + envsubst for AM | Alertmanager does not expand env natively |
| Resource limits + healthchecks | Protect the monitoring host |

---

## Requirements

- Ubuntu Server 24.04 LTS (recommended), Debian 12, or Proxmox VE host
- Docker Engine 24+ and Docker Compose v2 plugin
- Minimum 4 CPU / 8 GB RAM / 50 GB SSD
- Recommended 8+ CPU / 16–32 GB RAM / 200+ GB for medium–large

---

## Quick Start

```bash
git clone https://github.com/ucupcreativenetwork-glitch/dashboardgravana-monitoring.git
cd dashboardgravana-monitoring

sudo ./scripts/install.sh
cp .env.example .env
nano .env   # GF_SECURITY_ADMIN_PASSWORD, DISCORD_WEBHOOK_URL, Telegram, SMTP…

sudo ./scripts/install.sh --start
# or: docker compose up -d
# Proxmox: docker compose --profile pve up -d
```

| Service | Default URL |
|---------|-------------|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |
| Uptime Kuma | http://localhost:3001 |
| Loki | http://localhost:3100 |

Credentials: from `.env`. TLS: [docs/REVERSE-PROXY.md](docs/REVERSE-PROXY.md).

---

## Dashboards

**35 production dashboards** under `grafana/dashboards/` (auto-provisioned).

| Range | Coverage |
|-------|----------|
| 01–05 | Executive, Infrastructure, Linux, Docker, Container |
| 06–09 | Proxmox Cluster/Node, VMs, LXC |
| 10–13 | Storage, Network, Bandwidth, Internet/Probes |
| 14–19 | Application, Nextcloud, Immich, MariaDB, Redis, Shinobi |
| 20–26 | Alert Center, Security, SSL, Cloudflare, pfSense, Mikrotik, UPS |
| 27–31 | Temperature, SMART, Backup, Logs, Audit |
| 32–35 | Performance, Capacity, Business, Datacenter |

---

## Configuration

Driven by `.env` (see `.env.example`).

- **Targets:** `prometheus/targets/*.json` (file_sd) — nodes, blackbox, PVE API
- **Alerts:** render with `./scripts/render-alertmanager-config.sh` after editing `.env`
- **Proxmox:** [docs/PROXMOX.md](docs/PROXMOX.md)

---

## Backup & Restore

```bash
./scripts/backup.sh
./scripts/restore.sh backup/dg-backup-YYYYMMDD-HHMMSS.tar.gz
```

Details: [docs/BACKUP.md](docs/BACKUP.md).

---

## Security

See [SECURITY.md](SECURITY.md). Never commit `.env`. TLS at the edge. Least-privilege exporters. CI scans for private keys.

---

## Scaling & HA

Federation, remote_write (Thanos/Mimir), Loki object storage, Helm — see [ROADMAP.md](ROADMAP.md). Alertmanager clustering flags already set.

---

## Upgrade

```bash
./scripts/update.sh
# or: git pull && docker compose pull && docker compose up -d
```

---

## Troubleshooting

```bash
./scripts/healthcheck.sh
docker compose logs -f grafana prometheus alertmanager
curl -s localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, health}'
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Keep the **Validate** workflow green.

## License

MIT — see [LICENSE](LICENSE).

## Maintainers

- [@ucupcreativenetwork-glitch](https://github.com/ucupcreativenetwork-glitch)

---

**DashboardGravana** — Own your observability.
