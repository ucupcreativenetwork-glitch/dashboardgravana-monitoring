# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Prometheus **file_sd** targets (`prometheus/targets/*.json`) for nodes, blackbox HTTP/ICMP/TCP/SSL/DNS, and PVE API
- Expanded Blackbox modules (`tls_connect`, `http_2xx_ssl`, DNS) + `CAP_NET_RAW` for ICMP
- **PVE profile** (`docker compose --profile pve`) with token-safe `pve.yml.example`, file_sd scrape, `docs/PROXMOX.md`
- Alertmanager **Discord + Telegram + Email** receivers with `alertmanager.yml.tmpl` and `scripts/render-alertmanager-config.sh` (envsubst)
- CI hardening: YAML/JSON/Compose/shellcheck/promtool/secrets jobs that **fail** on broken configs
- Docs: `docs/BLACKBOX.md`, `docs/TELEGRAM.md`, `docs/REVERSE-PROXY.md`, `docs/BACKUP.md`, `ROADMAP.md`
- Backup retention (`DG_BACKUP_KEEP`), optional quiesce (`DG_BACKUP_QUIESCE`), safer restore with `--yes`

### Changed
- Node-exporter and blackbox scrape jobs prefer file_sd over static lists
- `install.sh` / `update.sh` render Alertmanager config before stack start
- README documentation index expanded

## [0.2.0] - 2026-08-04

### Added
- Full set of Grafana dashboards 01–35 (Executive through Datacenter)
- Extended alert rules: services, network, hardware, backup, HTTP 5xx
- Proxmox alert rules and exporter profile
- Runbooks: node-down, SSL, filesystem, UPS
- Loki logs + audit dashboards

## [0.1.0] - 2026-08-04

### Added
- Initial production monitoring stack scaffold
- Docker Compose core services
- Prometheus, Alertmanager, Loki, Grafana provisioning
- Executive Overview dashboard
- Install / backup / restore scripts
- GitHub CI and templates
