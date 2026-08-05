# Proxmox VE Monitoring

> Manual chapter: [manual/06-exporters-proxmox-notifications.md](manual/06-exporters-proxmox-notifications.md)

## Overview

Metrics come from **pve-exporter** (Proxmox API) scraped by Prometheus. Dashboards:

- **06** Proxmox Cluster (`dg-proxmox-cluster`)
- **07** Proxmox Node (`dg-proxmox-node`)
- **08** Virtual Machines (`dg-vms`)
- **09** LXC Containers (`dg-lxc`)

## Setup

1. In Proxmox, create a user (or API token) with **PVEAuditor** (or minimal read for metrics).  
   **Do not** use full Administrator for monitoring.

2. Configure exporter:

```bash
cp pve-exporter/pve.yml.example pve-exporter/pve.yml
chmod 600 pve-exporter/pve.yml
nano pve-exporter/pve.yml
```

3. Set related variables in `.env` if your Compose file references `PVE_*`.

4. Enable the service in `docker-compose.yml` (uncomment `pve-exporter` / profile) and the `pve` scrape job in `prometheus/prometheus.yml`.

5. Apply:

```bash
docker compose up -d
curl -X POST http://localhost:9090/-/reload
```

6. Confirm target **UP** in Prometheus → Status → Targets, then open Proxmox dashboards in Grafana.

## Security

- Token scope: audit/read only  
- File mode `600` on `pve.yml`  
- Never commit real tokens (keep `pve.yml` out of git; only `.example` is tracked)
