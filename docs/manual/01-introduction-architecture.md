# Introduction & Architecture

[← Manual Index](../MANUAL.md)

## 1. Introduction

DashboardGravana is a **production-grade, fully self-hosted observability stack** designed for:

- HomeLab
- SMB / mid-size IT
- Enterprise edge / branch
- Datacenter single-site and multi-node

It aims to provide capabilities comparable to Datadog, Zabbix, PRTG, Grafana Cloud, Prometheus Operator, and Elastic Observability **without vendor lock-in**.

### Design principles

| Principle | Implementation |
|-----------|----------------|
| Production-ready | No placeholders, healthchecks, resource limits, retention policies |
| Modular | Compose services can be enabled/disabled via profiles |
| Secure by default | Secrets in `.env`, no anonymous Grafana, TLS at the edge |
| Observable | The stack monitors itself (Prometheus, Grafana, Loki, Alertmanager) |
| Recoverable | Documented backup/restore and runbooks |
| Scalable | Federation, remote_write, and HA paths documented |

---

## 2. Architecture

```
                    ┌─────────────────────────────────────────────────┐
                    │              Reverse Proxy (TLS)                │
                    │         Nginx / Traefik / Caddy / Cloudflare    │
                    └────────────┬───────────────┬────────────────────┘
                                 │               │
              ┌──────────────────▼───┐     ┌─────▼──────────────────┐
              │      Grafana         │     │     Uptime Kuma        │
              │  Dashboards / UI     │     │  Synthetic / Status    │
              └──────────┬───────────┘     └────────────────────────┘
                         │
         ┌───────────────┼───────────────────────────────┐
         │               │                               │
┌────────▼──────┐ ┌──────▼──────┐ ┌──────────▼──────────┐
│  Prometheus   │ │ Alertmanager│ │        Loki         │
│  Metrics TSDB │ │  Routing    │ │   Log aggregation   │
└───────┬───────┘ └──────┬──────┘ └──────────▲──────────┘
        │                │                   │
        │         Discord / Telegram / Email │
        │                                    │
┌───────▼────────────────────────────────────┴──────────┐
│  Exporters & Agents                                    │
│  node-exporter · cAdvisor · blackbox · pve-exporter    │
│  Promtail (Docker / journal / syslog / nginx)          │
└────────────────────────────────────────────────────────┘
```

For deeper design notes see [docs/ARCHITECTURE.md](ARCHITECTURE.md).

### Component roles

| Component | Role |
|-----------|------|
| **Grafana** | Visualization, dashboards, Explore, alerting UI |
| **Prometheus** | Metrics TSDB, scrape, recording rules, alert evaluation |
| **Alertmanager** | Grouping, inhibition, routing to Discord/Telegram/Email |
| **Loki** | Log storage and query (LogQL) |
| **Promtail** | Log shipping (journal, Docker, files) |
| **Node Exporter** | Host CPU, memory, disk, network, filesystem |
| **cAdvisor** | Container metrics |
| **Blackbox Exporter** | HTTP/HTTPS/ICMP/TCP probes, SSL expiry |
| **PVE Exporter** | Proxmox VE cluster / node / VM / LXC / storage |
| **Uptime Kuma** | Status pages and synthetic checks (complementary) |

---

[← Manual Index](../MANUAL.md)
