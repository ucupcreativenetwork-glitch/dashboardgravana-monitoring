# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

**Do not open public issues for security vulnerabilities.**

Please report security issues privately via:

1. GitHub Security Advisories (preferred) — use the "Report a vulnerability" button on the repository Security tab.
2. Email the maintainers (see CODEOWNERS).

We aim to acknowledge reports within 48 hours and provide a remediation timeline within 7 days for critical issues.

## Security Best Practices for Operators

- Never commit `.env` or real credentials.
- Rotate Grafana admin password, Discord webhooks, Telegram tokens, and SMTP credentials regularly.
- Place all services behind a reverse proxy (Nginx, Traefik, Caddy) with TLS.
- Restrict Prometheus and Alertmanager ports to internal networks or authenticated reverse proxies.
- Enable authentication on Grafana and disable anonymous access.
- Use network policies / firewall rules so only the monitoring host can scrape exporters.
- Keep images updated; subscribe to GitHub Dependabot alerts.
- Review Alertmanager templates for information disclosure before enabling external webhooks.
- For production multi-tenant use, migrate secrets to Docker Secrets, HashiCorp Vault, or sealed-secrets (K8s).

## Known Considerations

- cAdvisor and node-exporter require elevated privileges / host mounts. Isolate them on the monitoring host.
- Blackbox ICMP probes need `CAP_NET_RAW`. Prefer HTTP probes when possible.
- PVE exporter credentials have high privilege; use dedicated monitoring API tokens with least privilege.
