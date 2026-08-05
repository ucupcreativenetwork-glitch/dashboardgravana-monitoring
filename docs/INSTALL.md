# Installation

Production install on **Ubuntu 24.04 LTS**, **Debian 12**, or **Proxmox VE** host.

## 1. Prerequisites

- Root or sudo
- 4+ CPU / 8+ GB RAM / 50+ GB disk
- Outbound HTTPS

## 2. Clone & configure

```bash
git clone https://github.com/ucupcreativenetwork-glitch/dashboardgravana-monitoring.git
cd dashboardgravana-monitoring
sudo ./scripts/install.sh
cp -n .env.example .env
nano .env
```

Set at least `GF_SECURITY_ADMIN_PASSWORD` and `DISCORD_WEBHOOK_URL`.

## 3. Start

```bash
./scripts/render-alertmanager-config.sh
sudo ./scripts/install.sh --start
```

Optional: `--profile pve` / `--profile exporters`.

## 4. Verify

```bash
./scripts/healthcheck.sh
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health}'
```

## 5. TLS

See [REVERSE-PROXY.md](REVERSE-PROXY.md). Use `docker-compose.override.example.yml` for localhost binds.

## Related

- [BACKUP.md](BACKUP.md) · [PROXMOX.md](PROXMOX.md) · [EXPORTERS.md](EXPORTERS.md) · [ALERTMANAGER.md](ALERTMANAGER.md)
