# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial production-grade monitoring stack scaffold
- Docker Compose with Grafana, Prometheus, Alertmanager, Loki, Promtail, Node Exporter, cAdvisor, Blackbox Exporter, Uptime Kuma
- Prometheus scrape configs, recording rules, and core alert rules (infrastructure, containers, application)
- Alertmanager with Discord (primary), Telegram and Email ready receivers, inhibition and severity routing
- Loki single-binary + Promtail with Docker, journal and file discovery
- Grafana provisioning (Prometheus, Loki, Alertmanager datasources)
- Executive Overview dashboard
- Comprehensive `.env.example`, security policy, contribution guide
- GitHub issue / PR templates and Dependabot configuration

### Security
- Secrets isolated via `.env`; `.gitignore` blocks credentials
- No anonymous Grafana access by default
- Resource limits and healthchecks on all critical services

## [0.1.0] - 2026-08-04

- Project bootstrap
