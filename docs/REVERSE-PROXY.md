# Reverse Proxy & TLS

Expose Grafana (and optionally other UIs) behind HTTPS. **Do not** publish Prometheus, Alertmanager, or exporters to the public internet without authentication and network controls.

## Recommended public surface

| Path / Host | Backend | Public? |
|-------------|---------|---------|
| `https://monitoring.example.com/` | Grafana `:3000` | Yes (SSO/password) |
| `https://status.example.com/` | Uptime Kuma `:3001` | Optional |
| Prometheus `:9090` | — | **No** (VPN / private only) |
| Alertmanager `:9093` | — | **No** |
| Loki `:3100` | — | **No** |
| Exporters | — | **No** |

Set in `.env`:

```bash
DOMAIN=monitoring.example.com
PUBLIC_URL=https://monitoring.example.com
GF_SERVER_ROOT_URL=https://monitoring.example.com
```

Then restart Grafana after proxy is live.

---

## Nginx (Ubuntu / Debian)

```bash
sudo apt-get install -y nginx certbot python3-certbot-nginx
```

`/etc/nginx/sites-available/dashboardgravana`:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name monitoring.example.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name monitoring.example.com;

    ssl_certificate     /etc/letsencrypt/live/monitoring.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/monitoring.example.com/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;

    client_max_body_size 32m;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade           $http_upgrade;
        proxy_set_header Connection        $connection_upgrade;
        proxy_read_timeout 300s;
    }
}

map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}
```

```bash
sudo ln -sf /etc/nginx/sites-available/dashboardgravana /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d monitoring.example.com
```

**Firewall:** allow 80/443 only from required networks; keep 9090/9093/3100/9100 closed on the public interface.

---

## Caddy (automatic HTTPS)

```caddy
monitoring.example.com {
    encode gzip
    reverse_proxy 127.0.0.1:3000
    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains"
        X-Content-Type-Options nosniff
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```

---

## Traefik

Prefer labels when Traefik shares the Compose network; do not publish Grafana host port publicly without TLS termination.

---

## Cloudflare

1. DNS `A`/`AAAA` or Tunnel.
2. SSL/TLS mode: **Full (strict)** with valid origin cert.
3. Prefer Cloudflare Tunnel so host 443 need not be open.
4. Never put Prometheus/Alertmanager on an unauthenticated public hostname.

---

## Grafana root URL

```bash
GF_SERVER_ROOT_URL=https://monitoring.example.com
docker compose up -d grafana
```

---

## Bind ports privately

```yaml
# docker-compose.override.yml (gitignored)
services:
  grafana:
    ports: ["127.0.0.1:3000:3000"]
  prometheus:
    ports: ["127.0.0.1:9090:9090"]
  alertmanager:
    ports: ["127.0.0.1:9093:9093"]
```

## Security checklist

- [ ] Only Grafana (optional status) on public HTTPS
- [ ] Strong admin password / SSO
- [ ] HSTS enabled
- [ ] Metrics/logs ports private
- [ ] `GF_SERVER_ROOT_URL` matches public URL
- [ ] Certificate auto-renewal

## Related

- [INSTALL.md](INSTALL.md) · [SECURITY.md](../SECURITY.md) · [ALERTMANAGER.md](ALERTMANAGER.md)
