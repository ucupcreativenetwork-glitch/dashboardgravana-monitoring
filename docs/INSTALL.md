# Installation Guide

> Part of [Manual Book](MANUAL.md) · detailed chapter: [manual/02-installation.md](manual/02-installation.md)

## Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| OS | Ubuntu 24.04 LTS / Debian 12 / Proxmox VE | Ubuntu 24.04 LTS |
| CPU | 4 cores | 8+ |
| RAM | 8 GB | 16–32 GB |
| Disk | 50 GB SSD | 200+ GB SSD |
| Software | Docker Engine 24+, Compose v2 plugin | same |

## Quick install

```bash
git clone https://github.com/ucupcreativenetwork-glitch/dashboardgravana-monitoring.git
cd dashboardgravana-monitoring

sudo ./scripts/install.sh
cp .env.example .env
chmod 600 .env
nano .env   # set GF_SECURITY_ADMIN_PASSWORD, DISCORD_WEBHOOK_URL

sudo ./scripts/install.sh --start
# or: docker compose up -d
```

## Verify

```bash
./scripts/healthcheck.sh
docker compose ps
curl -s http://localhost:9090/-/ready
curl -s http://localhost:3000/api/health
```

| Service | URL |
|---------|-----|
| Grafana | http://localhost:3000 |
| Prometheus | http://localhost:9090 |
| Alertmanager | http://localhost:9093 |
| Uptime Kuma | http://localhost:3001 |
| Loki | http://localhost:3100 |

## Update / uninstall

```bash
./scripts/update.sh
./scripts/uninstall.sh          # keep volumes
./scripts/uninstall.sh --purge  # delete volumes (destructive)
```

## Next steps

1. [GRAFANA.md](GRAFANA.md) — datasources & dashboards  
2. [PROXMOX.md](PROXMOX.md) — enable PVE exporter  
3. [DISCORD.md](DISCORD.md) — alert notifications  
4. [ALERTMANAGER.md](ALERTMANAGER.md) — routing & silences  
5. [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — common issues  
