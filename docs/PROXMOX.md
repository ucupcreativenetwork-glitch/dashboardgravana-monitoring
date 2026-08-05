# Proxmox VE Monitoring

Production runbook for DashboardGravana + Proxmox VE.

> Related: [BLACKBOX.md](BLACKBOX.md) · Dashboards **06–09** · Rules `prometheus/rules/proxmox.yml`

## Architecture

```
Proxmox API (:8006)
        ▲
        │ HTTPS (API token, read-only)
        │
pve-exporter:9221  ◄── Prometheus job "pve" (file_sd → targets/pve.json)
        │
        └── metrics: pve_up, pve_cpu_usage, pve_guest_info, pve_storage_*, …
```

**Why profile `pve`**

- Core stack runs without Proxmox (HomeLab without hypervisor, pure Docker hosts).
- Enable only when needed: `docker compose --profile pve up -d`
- Alias profile `proxmox` is also accepted.

## 1. Create a least-privilege account on Proxmox

1. Datacenter → **Permissions** → **Users** → Add  
   - User: `monitoring@pve` (or `@pam`)  
   - Role: **PVEAuditor** (read-only audit)

2. Datacenter → **Permissions** → **API Tokens** → Add  
   - Token ID: `monitoring`  
   - Privilege Separation: **enabled** (recommended)  
   - Copy the token secret **once** (shown only at creation)

3. Assign permission path `/` (or specific nodes) with role **PVEAuditor** to `monitoring@pve!monitoring`.

**Do not** use the `root@pam` password for monitoring.

## 2. Configure the exporter

```bash
cp pve-exporter/pve.yml.example pve-exporter/pve.yml
chmod 600 pve-exporter/pve.yml
nano pve-exporter/pve.yml
```

Set:

```yaml
default:
  user: monitoring@pve
  token_name: monitoring
  token_value: "paste-token-secret-here"
  verify_ssl: false   # true if API cert is publicly trusted / internal CA mounted
```

`pve.yml` is **gitignored**. Only `pve.yml.example` is tracked.

## 3. Register Proxmox API targets

Edit `prometheus/targets/pve.json`:

```json
[
  {
    "targets": [
      "192.168.1.10:8006",
      "pve2.lab.local:8006"
    ],
    "labels": {
      "env": "production",
      "site": "dc1",
      "cluster": "homelab",
      "component": "proxmox"
    }
  }
]
```

- Targets are **Proxmox API** addresses (`host:8006`), not the exporter.
- Add/remove nodes without restarting Prometheus (file_sd refresh ≤30s).

## 4. Start the profile

```bash
docker compose --profile pve up -d
curl -X POST http://localhost:9090/-/reload
```

Verify:

```bash
docker ps --filter name=dg-pve-exporter

curl -sS "http://localhost:9221/pve?module=default&target=192.168.1.10:8006&cluster=1&node=1" | head

curl -s http://localhost:9090/api/v1/targets \
  | jq -r '.data.activeTargets[] | select(.labels.job=="pve") | {instance: .labels.instance, health}'
```

## 5. Grafana dashboards

| ID | Dashboard | UID |
|----|-----------|-----|
| 06 | Proxmox Cluster | `dg-proxmox-cluster` |
| 07 | Proxmox Node | `dg-proxmox-node` |
| 08 | Virtual Machines | `dg-vms` |
| 09 | LXC Containers | `dg-lxc` |

## 6. Alert rules

Defined in `prometheus/rules/proxmox.yml`:

| Alert | Severity | Meaning |
|-------|----------|---------|
| `ProxmoxNodeDown` | critical | Exporter/node unreachable |
| `ProxmoxVMDown` | warning | QEMU guest registered, no CPU metrics |
| `ProxmoxLXCDown` | warning | LXC registered, no CPU metrics |
| `ProxmoxStorageLow` | warning | Storage > 90% |

## Security checklist

- [ ] API token with **PVEAuditor** only
- [ ] `chmod 600 pve-exporter/pve.yml`
- [ ] `pve.yml` not committed
- [ ] Exporter port `9221` not exposed publicly
- [ ] Prefer private network to Proxmox `:8006`
- [ ] `verify_ssl: true` when certificates are valid

## Troubleshooting

| Symptom | Action |
|---------|--------|
| Profile container missing | `docker compose --profile pve up -d` |
| Auth errors | Token wrong / privilege path missing |
| `pve_up` empty | Check `targets/pve.json` host:8006 from container network |
| SSL errors | `verify_ssl: false` for lab certs |
| Job always down without Proxmox | Expected if profile not started |

```bash
docker logs dg-pve-exporter --tail 100
```

## Related

- `prometheus/targets/README.md` — file_sd format
- `prometheus/rules/proxmox.yml` — alerts
- `docs/INSTALL.md` — full stack install
