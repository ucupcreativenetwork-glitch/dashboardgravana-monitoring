# Optional Exporters

Core: node-exporter, cAdvisor, blackbox, optional pve-exporter.  
App exporters are opt-in via Compose profiles.

## Profiles

| Profile | Command | Services |
|---------|---------|----------|
| (default) | `docker compose up -d` | Core stack |
| `pve` | `docker compose --profile pve up -d` | + pve-exporter |
| `exporters` | `docker compose --profile exporters up -d` | + mysqld-exporter, redis-exporter |

## MySQL / Redis

See DSN/`REDIS_ADDR` in `.env.example`. Dashboards **17** / **18**.

## Host / hardware exporters

Windows, NUT, SMART, SNMP: **[HOST-EXPORTERS.md](HOST-EXPORTERS.md)** and `deploy/host-exporters/`.

## Security

- DB: SELECT/PROCESS only
- Do not expose exporter ports publicly
- Secrets only in `.env`
