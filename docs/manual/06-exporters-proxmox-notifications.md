# Exporters, Proxmox & Notifications

[← Manual Index](../MANUAL.md)

## 11. Exporters & Targets

### 11.1 Linux hosts

Install Node Exporter on each host (or scrape remote agents). Ensure port 9100 is reachable from the monitoring server only.

Firewall: allow **monitoring server → target:9100** only.

### 11.2 Docker hosts

cAdvisor runs on the monitoring host by default. For remote Docker hosts, deploy cAdvisor (or alternative) on those hosts and add scrape jobs.

### 11.3 Blackbox probes

Config: `prometheus/blackbox.yml`

Modules typically include `http_2xx` / `https_2xx`, `icmp`, `tcp_connect`.

Define probe targets in `prometheus.yml` (static or file_sd). SSL expiry uses `probe_ssl_earliest_cert_expiry`.

### 11.4 Application exporters

| App | Approach |
|-----|----------|
| MariaDB/MySQL | `mysqld_exporter` + blackbox |
| Redis | `redis_exporter` + blackbox |
| Nextcloud / Immich / Shinobi | Blackbox HTTP + optional app metrics |
| Nginx/Apache | `nginx-prometheus-exporter` / `mod_status` exporters |

Wire new exporters as Compose services or remote endpoints, then add scrape jobs.

---

## 12. Proxmox Monitoring

### 12.1 Enable PVE exporter

1. Create a Proxmox user/token with **PVEAuditor** (or least privilege for metrics).
2. Copy `pve-exporter/pve.yml.example` → `pve-exporter/pve.yml` and fill credentials.
3. Set `PVE_*` variables in `.env` if used by Compose.
4. Uncomment `pve-exporter` service in `docker-compose.yml` (profile or direct).
5. Uncomment `pve` scrape job in `prometheus/prometheus.yml`.
6. `docker compose up -d` and reload Prometheus.

### 12.2 Dashboards

- **06 Proxmox Cluster** — guests, node trends, storage
- **07 Proxmox Node** — per-node CPU/memory
- **08 VMs** / **09 LXC** — guest inventory and usage

### 12.3 Security note

Never grant Administrator to the monitoring token. Store `pve.yml` with mode `600` and keep it out of git.

---

## 13. Notification Channels

### 13.1 Discord

1. Server Settings → Integrations → Webhooks → New Webhook
2. Copy URL into `DISCORD_WEBHOOK_URL` in `.env`
3. Restart Alertmanager / stack

### 13.2 Telegram

1. Create bot via `@BotFather`
2. Get chat ID (user or group)
3. Set `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`

### 13.3 Email

Configure SMTP variables in `.env` and matching receivers in `alertmanager/alertmanager.yml`.

```bash
docker compose logs alertmanager
```

---

[← Manual Index](../MANUAL.md)
