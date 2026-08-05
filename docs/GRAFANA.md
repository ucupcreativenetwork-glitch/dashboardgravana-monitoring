# Grafana

> Manual: [manual/03-configuration.md](manual/03-configuration.md), [manual/04-dashboards.md](manual/04-dashboards.md)

## Access

- URL: http://localhost:3000 (or your reverse-proxy hostname)
- User/password: `GF_SECURITY_ADMIN_USER` / `GF_SECURITY_ADMIN_PASSWORD` in `.env`

## Provisioning

| Path | Purpose |
|------|---------|
| `grafana/provisioning/datasources/datasources.yml` | Prometheus + Loki |
| `grafana/provisioning/dashboards/dashboards.yml` | Auto-load JSON dashboards |
| `grafana/dashboards/` | **35** dashboard JSON files |

Expected datasource UIDs in panels: **Prometheus**, **Loki**.

## Dashboard catalogue (summary)

| Range | Topics |
|-------|--------|
| 01–05 | Executive, Infrastructure, Linux, Docker, Container |
| 06–09 | Proxmox Cluster/Node, VMs, LXC |
| 10–13 | Storage, Network, Bandwidth, Internet probes |
| 14–19 | Apps (Nextcloud, Immich, MariaDB, Redis, Shinobi) |
| 20–26 | Alerts, Security, SSL, Cloudflare, pfSense, Mikrotik, UPS |
| 27–31 | Temperature, SMART, Backup, Logs, Audit |
| 32–35 | Performance, Capacity, Business, Datacenter |

Full table: [manual/04-dashboards.md](manual/04-dashboards.md).

## Tips

- Filter with the **Instance** variable  
- Use dashboard **Navigation** links  
- Prefer **Explore** for ad-hoc PromQL/LogQL  

## Production

Put Grafana behind TLS (nginx/Traefik/Caddy). Disable anonymous access. Consider OAuth/LDAP for teams.
