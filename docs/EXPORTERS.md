# Optional Exporters

Core stack metrics come from **node-exporter**, **cAdvisor**, **blackbox**, and optional **pve-exporter**.  
Application exporters are **opt-in** via Compose profiles so HomeLab installs stay lean.

## Profiles

| Profile | Command | Services |
|---------|---------|----------|
| (default) | `docker compose up -d` | Core stack |
| `pve` | `docker compose --profile pve up -d` | + pve-exporter |
| `exporters` | `docker compose --profile exporters up -d` | + mysqld-exporter, redis-exporter |

```bash
docker compose --profile pve --profile exporters up -d
```

## MySQL / MariaDB

```sql
CREATE USER 'monitoring'@'%' IDENTIFIED BY 'STRONG_PASSWORD';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'monitoring'@'%';
FLUSH PRIVILEGES;
```

```bash
MYSQL_EXPORTER_DSN=monitoring:STRONG_PASSWORD@(mariadb:3306)/
docker compose --profile exporters up -d
```

Dashboard **17-MariaDB**.

## Redis

```bash
REDIS_EXPORTER_ADDR=redis://:password@redis:6379
docker compose --profile exporters up -d
```

Dashboard **18-Redis**.

## NUT / SMART / SNMP / Windows

Run on the host (device access). Point `prometheus/targets/` at the exporter IP:port. See in-repo details for patterns.

## Security

- DB: SELECT/PROCESS only
- Do not expose exporter ports publicly
- Secrets only in `.env`

## Related

- [PROXMOX.md](PROXMOX.md) · [BLACKBOX.md](BLACKBOX.md)
