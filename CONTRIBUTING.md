# Contributing to DashboardGravana Monitoring

Thank you for contributing. This project aims to be the best open-source, self-hosted monitoring platform for HomeLab, SMB, Enterprise and Datacenter use.

## Development Principles

1. **Production-ready only** — no demo, placeholder, or mock configurations.
2. **Document every decision** — why a setting exists, security implications, scaling impact.
3. **Modular** — new exporters, dashboards, and alert groups must be self-contained.
4. **Validated** — YAML, JSON, and Compose must pass validation before merge.
5. **Backward-compatible** where reasonable; breaking changes require CHANGELOG entry and migration notes.

## How to Contribute

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Make changes following the existing structure and coding style.
4. Validate:
   - `docker compose config` (or equivalent YAML validation)
   - JSON dashboards with `jq`
   - Alert rules with `promtool check rules` if available
5. Update documentation and CHANGELOG.md.
6. Open a Pull Request using the provided template.

## Dashboard Guidelines

- Use Grafana schemaVersion ≥ 39 (Grafana 11.x).
- Prefer recording rules for expensive queries.
- Include variables for instance / job / environment.
- Dark theme, professional layout, consistent color thresholds.
- Unique `uid` values; never reuse or invent fake panel IDs arbitrarily.
- Tag dashboards with `dashboardgravana` plus category tags.

## Alert Guidelines

- Every alert must have `severity`, `summary`, and `description`.
- Prefer `runbook_url` and `dashboard_url` annotations.
- Use inhibition rules to reduce noise.
- Test grouping and silence behavior.

## Commit Messages

Follow Conventional Commits:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `chore: ...`
- `refactor: ...`
- `security: ...`

## Code of Conduct

Be respectful. Focus on technical merit. Harassment or personal attacks will not be tolerated.
