# Configuration & Access

[← Manual Index](../MANUAL.md)

## 5. First-Time Configuration

### 5.1 Environment file

```bash
cp .env.example .env
chmod 600 .env
nano .env
```

**Must set:**

| Variable | Purpose |
|----------|---------|
| `GF_SECURITY_ADMIN_USER` | Grafana admin username |
| `GF_SECURITY_ADMIN_PASSWORD` | Grafana admin password (**strong, unique**) |
| `DISCORD_WEBHOOK_URL` | Primary alert channel (recommended) |

**Strongly recommended:**

| Variable | Purpose |
|----------|---------|
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `TELEGRAM_CHAT_ID` | Telegram chat / group ID |
| `SMTP_*` | Email alerts via Alertmanager |
| `PROMETHEUS_RETENTION_TIME` | e.g. `30d` |
| `PROMETHEUS_RETENTION_SIZE` | e.g. `50GB` |

Never commit `.env` to git.

### 5.2 Timezone and locale

Ensure the host timezone is correct (affects log timestamps and Grafana browser TZ default):

```bash
timedatectl status
sudo timedatectl set-timezone Asia/Jakarta   # example
```

### 5.3 Reverse proxy (production)

Do **not** expose Grafana/Prometheus/Alertmanager directly to the internet without TLS and access control.

Example nginx location sketch (TLS terminated at nginx):

```nginx
server {
    listen 443 ssl http2;
    server_name monitoring.example.com;
    # ssl_certificate / ssl_certificate_key ...

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

Restrict Prometheus (`:9090`) and Alertmanager (`:9093`) to internal networks or VPN.

---

## 6. Access & Default Ports

| Service | Port | URL (local) | Notes |
|---------|------|-------------|-------|
| Grafana | 3000 | http://localhost:3000 | Primary UI |
| Prometheus | 9090 | http://localhost:9090 | Metrics / targets / rules |
| Alertmanager | 9093 | http://localhost:9093 | Silences / status |
| Loki | 3100 | http://localhost:3100 | API only |
| Uptime Kuma | 3001 | http://localhost:3001 | Status / monitors |
| Node Exporter | 9100 | http://localhost:9100 | Host metrics |
| cAdvisor | 8080 | http://localhost:8080 | Container metrics |
| Blackbox | 9115 | http://localhost:9115 | Probe exporter |
| PVE Exporter | 9221 | http://localhost:9221 | When enabled |

Default Grafana login: values from `.env`.

---

[← Manual Index](../MANUAL.md)
