# Prometheus File-Based Service Discovery (file_sd)

Production multi-target discovery for DashboardGravana.

## Why file_sd

- Add/remove hosts and probes **without** editing `prometheus.yml` or restarting Prometheus
- Safe for multi-node HomeLab / SMB / Enterprise fleets
- Compatible with Ansible, scripts, or CI that write JSON targets
- Refresh every 30s (configurable)

## Layout

| File | Purpose |
|------|---------|
| `nodes.json` | Node Exporter hosts (`:9100`) |
| `blackbox-http.json` | HTTP/HTTPS availability probes |
| `blackbox-icmp.json` | ICMP (ping) probes |
| `blackbox-tcp.json` | TCP port connectivity |
| `blackbox-ssl.json` | TLS certificate expiry / handshake |
| `blackbox-dns.json` | DNS resolution checks |
| `pve.json` | Proxmox API endpoints (`host:8006`) |

## JSON format

Prometheus expects a list of groups:

```json
[
  {
    "targets": ["host1:9100", "host2:9100"],
    "labels": {
      "env": "production",
      "site": "dc1",
      "role": "compute"
    }
  }
]
```

- `targets` — list of `host:port` (or URL for blackbox HTTP)
- `labels` — attached to every series from those targets

## How to add a Linux host

1. Install Node Exporter on the host (or use the stack’s agent pattern).
2. Open firewall for TCP 9100 from the monitoring server only.
3. Append to `nodes.json`.
4. Wait ≤30s — target appears in Prometheus → Status → Targets.

## Proxmox API targets

Edit `pve.json` with `host:8006` (API), not the exporter port. See `docs/PROXMOX.md`.

## Security

- Never put secrets in target labels.
- Restrict Node Exporter and Blackbox to private network / firewall allowlist.
- Prefer read-only bind mounts (already configured in `docker-compose.yml`).

## Validation

```bash
python3 -m json.tool prometheus/targets/nodes.json
curl -X POST http://localhost:9090/-/reload
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, instance, health}'
```

## Related

- `docs/BLACKBOX.md` — probe modules and alert wiring
- `docs/PROXMOX.md` — PVE exporter profile
- Grafana dashboards **13-Internet**, **22-SSL**, **06–09 Proxmox**
