# Operations, Troubleshooting & FAQ

[← Manual Index](../MANUAL.md)

## 18. Operations Runbook

### Daily / weekly

- Review **Alert Center** dashboard and silences
- Check disk usage on monitoring host
- Confirm Discord/Telegram delivery (test alert monthly)

### After infrastructure change

- Update `prometheus/targets/*.json`
- Reload Prometheus
- Confirm new series on Infrastructure / Linux dashboards

### Capacity

- Watch **Capacity Planning** dashboard
- Adjust `PROMETHEUS_RETENTION_*` and Loki retention before disks fill

---

## 19. Troubleshooting

| Symptom | Checks |
|---------|--------|
| Empty Grafana panels | Prometheus up? Targets healthy? Recording rules loaded? Time range? |
| No Discord alerts | `DISCORD_WEBHOOK_URL`, Alertmanager config/logs, inhibition |
| Missing node metrics | node-exporter running, firewall, scrape job, label matchers |
| High disk usage | Retention settings, Loki volume, unused images |
| cAdvisor errors | Privileged mode, host mounts, kernel permissions |
| Proxmox metrics missing | Token rights, `pve.yml`, scrape job enabled, TLS to PVE API |
| SSL panels empty | Blackbox HTTPS probes configured for those endpoints |

### Useful commands

```bash
docker compose ps
docker compose logs -f grafana prometheus alertmanager loki promtail

curl -s localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, instance, health}'
curl -s localhost:9090/api/v1/rules | jq '.data.groups[].name'
curl -s localhost:9093/api/v2/status
```

### Grafana datasource

Provisioning path: `grafana/provisioning/datasources/datasources.yml`  
UIDs expected by dashboards: `Prometheus`, `Loki`.

---

## 20. FAQ

**Q: Can I run this on Proxmox itself?**  
A: Yes. Prefer a dedicated VM or privileged LXC with Docker. Avoid overloading critical hypervisors.

**Q: Is Kubernetes required?**  
A: No. Docker Compose is the primary path. K8s/Helm is on the roadmap.

**Q: How do I monitor Windows?**  
A: Use windows_exporter, scrape from Prometheus, and extend dashboards/rules as needed.

**Q: Why recording rules?**  
A: Faster dashboards, lower Prometheus load, consistent metric names across panels.

**Q: Can I disable Uptime Kuma?**  
A: Yes — remove or profile-gate the service in Compose if you only want Prometheus blackbox.

**Q: How many hosts can one node handle?**  
A: Depends on scrape interval, cardinality, and retention. Start with defaults; scale vertically or federate when CPU/IO or disk grows.

---

## 21. Appendix

### Directory map

```
dashboardgravana-monitoring/
├── docker-compose.yml
├── .env.example
├── scripts/
├── prometheus/
├── alertmanager/
├── loki/
├── promtail/
├── grafana/
│   ├── provisioning/
│   └── dashboards/    # 01–35
├── pve-exporter/
├── docs/
│   ├── MANUAL.md
│   ├── MANUAL-FULL.md
│   ├── manual/
│   ├── ARCHITECTURE.md
│   └── runbooks/
└── .github/
```

### Related documents

| Document | Path |
|----------|------|
| Architecture | [docs/ARCHITECTURE.md](../ARCHITECTURE.md) |
| Security policy | [SECURITY.md](../../SECURITY.md) |
| Contributing | [CONTRIBUTING.md](../../CONTRIBUTING.md) |
| Changelog | [CHANGELOG.md](../../CHANGELOG.md) |
| License | [LICENSE](../../LICENSE) |

### Support

- GitHub Issues: bug / feature / security / question templates
- Security issues: follow SECURITY.md (private disclosure)

---

**DashboardGravana** — Own your observability.

*Manual Book v1.0.0 — maintainers: @ucupcreativenetwork-glitch*

[← Manual Index](../MANUAL.md)
