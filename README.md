# DashboardGravana Monitoring

**Production-grade, fully self-hosted Open Source Monitoring Stack** for HomeLab, SMB, Enterprise and Datacenter.

Similar in capability to Datadog, Zabbix, PRTG, Grafana Cloud, Prometheus Operator and Elastic Observability — without vendor lock-in.

---

## Documentation

- **[Manual Book](docs/MANUAL.md)** — installation, configuration, operations, troubleshooting, FAQ
- **[Full Manual (single file)](docs/MANUAL-FULL.md)** — complete handbook in one document
- [Architecture](docs/ARCHITECTURE.md)
- [Runbooks](docs/runbooks/)

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
| Secrets via `.env` | Simple; migrate to Vault when needed |
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
nano .env   # set GF_SECURITY_ADMIN_PASSWORD, DISCORD_WEBHOOK_URL, etc.

sudo ./scripts/install.sh --start
# or: docker compose up -d
```

| Service | Default URL |
|---------|-------------|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |
| Uptime Kuma | http://localhost:3001 |
| Loki | http://localhost:3100 |

Credentials: from `.env`. Full steps: **[Manual Book](docs/MANUAL.md)**.

---

## Dashboards

**35 production dashboards** auto-provisioned under `grafana/dashboards/`.

| Range | Coverage |
|-------|----------|
| 01–05 | Executive, Infrastructure, Linux, Docker, Container |
| 06–09 | Proxmox Cluster/Node, VMs, LXC |
| 10–13 | Storage, Network, Bandwidth, Internet/Probes |
| 14–19 | Application, Nextcloud, Immich, MariaDB, Redis, Shinobi |
| 20–26 | Alert Center, Security, SSL, Cloudflare, pfSense, Mikrotik, UPS |
| 27–31 | Temperature, SMART, Backup, Logs, Audit |
| 32–35 | Performance, Capacity, Business, Datacenter |

Details: [docs/manual/04-dashboards.md](docs/manual/04-dashboards.md).

---

## Configuration

Driven by `.env` (see `.env.example`). Critical: `GF_SECURITY_ADMIN_PASSWORD`, `DISCORD_WEBHOOK_URL`, optional Telegram/SMTP/PVE vars.

Adding targets: prefer `prometheus/targets/*.json` with file_sd. Proxmox: see [Manual ch.06](docs/manual/06-exporters-proxmox-notifications.md).

---

## Backup & Restore

```bash
./scripts/backup.sh
./scripts/restore.sh <archive.tar.gz>
```

---

## Security

See [SECURITY.md](SECURITY.md). Never commit `.env`. TLS at the edge. Least-privilege exporters.

---

## Scaling & HA

Federation, remote_write (Thanos/Mimir), Loki object storage, Helm (roadmap). Alertmanager clustering flags already set.

---

## Upgrade

```bash
git pull && docker compose pull && docker compose up -d
```

---

## Troubleshooting

| Symptom | Check |
|---------|-------|
| Empty Grafana panels | Prometheus targets / recording rules |
| No Discord alerts | Webhook URL, Alertmanager logs |
| Node metrics missing | node-exporter, firewall |

```bash
docker compose logs -f grafana prometheus alertmanager
curl -s localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, health}'
```

Full guide: [ch.08](docs/manual/08-operations-faq.md).

---

## Roadmap

- [x] Full set of 35 enterprise dashboards
- [x] Manual Book (operations handbook)
- [ ] Exporters fully wired (PVE / edge network / UPS)
- [ ] Helm chart + Kubernetes manifests
- [ ] Thanos / Mimir optional profile
- [ ] Ansible / Terraform modules

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).

## Maintainers

- [@ucupcreativenetwork-glitch](https://github.com/ucupcreativenetwork-glitch)

---

**DashboardGravana** — Own your observability.
