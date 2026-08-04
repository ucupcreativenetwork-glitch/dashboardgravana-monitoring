# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Full set of Grafana dashboards 01–35 (Executive through Datacenter)
- Extended alert rules: services (MariaDB, Redis, Nextcloud, Immich, Shinobi), network (pfSense, Mikrotik, Cloudflare), hardware (UPS, SMART, temperature), backup, HTTP 5xx
- Proxmox alert rules and PVE exporter profile (`docker compose --profile proxmox`)
- Runbooks: node-down, SSL, filesystem, UPS
- Loki logs + audit dashboards

## [0.2.0] - 2026-08-04

### Added
- Complete dashboard suite and extended alerting

## [0.1.0] - 2026-08-04

### Added
- Initial production monitoring stack scaffold
- Docker Compose core services
- Prometheus, Alertmanager, Loki, Grafana provisioning
- Executive Overview dashboard
- Install / backup / restore scripts
- GitHub CI and templates
