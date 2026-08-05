# Roadmap — DashboardGravana Monitoring

## Done (current main)

- [x] Core stack: Grafana 11, Prometheus, Alertmanager, Loki, Promtail, node-exporter, cAdvisor, blackbox, Uptime Kuma
- [x] 35 production Grafana dashboards
- [x] Prometheus rules + recording rules
- [x] file_sd targets (nodes, blackbox, PVE, mysql, redis)
- [x] PVE profile + exporters profile (mysqld, redis)
- [x] Alertmanager Discord + Telegram + Email (envsubst)
- [x] Install / update / backup / restore / healthcheck
- [x] CI validation gates
- [x] Docs: INSTALL, REVERSE-PROXY, BACKUP, PROXMOX, BLACKBOX, EXPORTERS, ALERTMANAGER, TELEGRAM, ROADMAP
- [x] Stable Grafana datasource UIDs + provisioning

## Near term

- [ ] Host-side NUT / SMART / SNMP exporter recipes with sample file_sd
- [ ] Grafana folder permissions / default home dashboard
- [ ] Alertmanager HA pair example
- [ ] remote_write examples (Mimir / Thanos)
- [ ] Windows Exporter targets pack
- [ ] Screenshot pipeline for assets/

## Medium term

- [ ] Helm / Kubernetes manifests
- [ ] Ansible multi-node agents
- [ ] SSO examples (Authelia / Keycloak / Authentik)

## Non-goals

- Proprietary agents
- Committing live secrets or fake demo metrics as production truth
