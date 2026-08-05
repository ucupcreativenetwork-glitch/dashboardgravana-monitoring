# Roadmap — DashboardGravana Monitoring

Self-hosted observability platform for HomeLab, SMB, Enterprise, and Datacenter.

## Done (current main)

- [x] Core stack: Grafana 11, Prometheus, Alertmanager, Loki, Promtail, node-exporter, cAdvisor, blackbox, Uptime Kuma
- [x] 35 production Grafana dashboards (rich panels, stable UIDs)
- [x] Prometheus rules + recording rules
- [x] file_sd targets (nodes, blackbox, PVE API)
- [x] PVE exporter profile (`--profile pve`)
- [x] Alertmanager Discord + Telegram + Email (envsubst)
- [x] Install / update / backup / restore / healthcheck scripts
- [x] CI: YAML, JSON, compose, shellcheck, promtool, secrets scan
- [x] Docs: INSTALL, ARCHITECTURE, PROXMOX, BLACKBOX, ALERTMANAGER, TELEGRAM, REVERSE-PROXY, BACKUP

## Near term

- [ ] Optional Compose profiles for MySQL/MariaDB, Redis, SNMP, NUT, SMART exporters
- [ ] Grafana provisioning hardening (folders, home dashboard)
- [ ] Alertmanager HA pair example
- [ ] Prometheus remote_write examples (Mimir / Thanos)
- [ ] Windows Exporter scrape + dashboard polish
- [ ] Screenshot pipeline for `assets/screenshots/`

## Medium term

- [ ] Helm chart / Kubernetes manifests
- [ ] Ansible role for multi-node agents
- [ ] SSO examples (Authelia, Keycloak, Authentik)
- [ ] Capacity-planning recording rules pack

## Long term

- [ ] Optional eBPF / continuous profiling
- [ ] Multi-tenant org documentation
- [ ] Signed release tags

## Non-goals

- Replacing full commercial APM as primary product
- Proprietary agent binaries
- Committing live secrets or fake demo metrics as production truth

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Keep CI (`Validate`) green.

## Versioning

Semantic Versioning. Breaking Compose renames → major; new dashboards/rules/docs → minor; fixes → patch.
