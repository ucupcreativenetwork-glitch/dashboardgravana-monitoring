# Dashboards Catalogue

[← Manual Index](../MANUAL.md)

## 7. Dashboards Catalogue

All dashboards under `grafana/dashboards/` are **auto-provisioned** on Grafana start.

| # | Title | UID | Primary data |
|---|-------|-----|----------------|
| 01 | Executive Overview | dg-executive-overview | Fleet health KPIs |
| 02 | Infrastructure Overview | dg-infrastructure | Targets, CPU/RAM, network |
| 03 | Linux Overview | dg-linux | Per-node Linux metrics |
| 04 | Docker Overview | dg-docker | cAdvisor aggregate |
| 05 | Container Overview | dg-container | Per-container CPU/RAM/net |
| 06 | Proxmox Cluster | dg-proxmox-cluster | Cluster guests/storage |
| 07 | Proxmox Node | dg-proxmox-node | Node CPU/memory |
| 08 | Virtual Machines | dg-vms | QEMU guests |
| 09 | LXC Containers | dg-lxc | LXC guests |
| 10 | Storage | dg-storage | Filesystems, disk IO |
| 11 | Network | dg-network | Interface traffic/errors |
| 12 | Bandwidth | dg-bandwidth | In/out bandwidth |
| 13 | Internet / Probes | dg-internet | Blackbox HTTP/ICMP |
| 14 | Application | dg-application | App probe overview |
| 15 | Nextcloud | dg-nextcloud | Reachability / latency |
| 16 | Immich | dg-immich | Reachability / latency |
| 17 | MariaDB | dg-mariadb | Probe + mysql_up |
| 18 | Redis | dg-redis | Probe + memory |
| 19 | Shinobi | dg-shinobi | Reachability / latency |
| 20 | Alert Center | dg-alert-center | Firing / pending alerts |
| 21 | Security | dg-security | SSL expiry risk |
| 22 | SSL Certificates | dg-ssl | Days remaining |
| 23 | Cloudflare | dg-cloudflare | Exporter (if present) |
| 24 | pfSense | dg-pfsense | Probe health |
| 25 | Mikrotik | dg-mikrotik | Probe health |
| 26 | UPS | dg-ups | Battery / load (NUT) |
| 27 | Temperature | dg-temperature | Hardware sensors |
| 28 | SMART | dg-smart | Disk health |
| 29 | Backup | dg-backup | Backup job signals |
| 30 | Logs | dg-logs | Loki log stream |
| 31 | Audit | dg-audit | Auth / sudo journal |
| 32 | Performance | dg-performance | CPU/RAM/load/IO |
| 33 | Capacity Planning | dg-capacity | Free ratios |
| 34 | Business Overview | dg-business | Availability / incidents |
| 35 | Datacenter Overview | dg-datacenter | Multi-node summary |

### Using dashboards

1. Open Grafana → **Dashboards** → browse folders or search by tag `dashboardgravana`.
2. Use the **Instance** variable (top) to filter hosts.
3. Use the **Navigation** dashboard link to jump between related views.
4. Prefer **Explore** for ad-hoc PromQL / LogQL.

---

[← Manual Index](../MANUAL.md)
