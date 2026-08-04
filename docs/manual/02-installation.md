# Requirements & Installation

[← Manual Index](../MANUAL.md)

## 3. System Requirements

### Minimum (small HomeLab / < 20 hosts)

| Resource | Value |
|----------|-------|
| OS | Ubuntu 24.04 LTS, Debian 12, or Proxmox VE host |
| CPU | 4 cores |
| RAM | 8 GB |
| Disk | 50 GB SSD |
| Docker | Engine 24+ with Compose v2 plugin |

### Recommended (SMB / medium)

| Resource | Value |
|----------|-------|
| CPU | 8+ cores |
| RAM | 16–32 GB |
| Disk | 200+ GB SSD (metrics + logs grow with retention) |
| Network | Stable outbound HTTPS for images and webhooks |

### Large / datacenter

- Prefer dedicated monitoring node(s)
- Plan for Prometheus retention + Loki retention on separate volume
- Consider remote_write (Thanos / Mimir) and Loki object storage

### Network

- Open inbound only what you need (prefer reverse proxy + TLS)
- Outbound: Docker Hub / GHCR, Discord, Telegram API, SMTP if used

---

## 4. Installation

### 4.1 Clone

```bash
git clone https://github.com/ucupcreativenetwork-glitch/dashboardgravana-monitoring.git
cd dashboardgravana-monitoring
```

### 4.2 Automated install

```bash
sudo ./scripts/install.sh
```

The script:

1. Installs Docker Engine + Compose plugin (Ubuntu/Debian/Proxmox-friendly)
2. Creates required directories
3. Copies `.env.example` → `.env` if missing
4. Sets secure file permissions on `.env`

### 4.3 Start the stack

```bash
# After editing .env (see section 5)
sudo ./scripts/install.sh --start

# or
docker compose up -d
```

### 4.4 Verify

```bash
docker compose ps
docker compose logs -f --tail=100

curl -s http://localhost:9090/-/ready
curl -s http://localhost:3000/api/health
curl -s http://localhost:3100/ready
curl -s http://localhost:9093/-/ready
```

---

[← Manual Index](../MANUAL.md)
