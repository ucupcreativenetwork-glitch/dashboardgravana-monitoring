# Roadmap — DashboardGravana Monitoring

## Done

- [x] Core stack + 35 dashboards + file_sd
- [x] Profiles: `pve`, `exporters`, `snmp`
- [x] Windows / NUT / SMART / SNMP host packs
- [x] Alertmanager Discord + Telegram + Email
- [x] CI, backup/restore, reverse-proxy docs
- [x] Grafana default home dashboard (`grafana/config/grafana.ini`)
- [x] Alertmanager HA example (`alertmanager/ha/`)
- [x] remote_write examples
- [x] SSO guide (`docs/SSO.md`)
- [x] Helm chart skeleton (`deploy/helm/`)
- [x] Ansible node_exporter (`deploy/ansible/`)

## Later / community

- [ ] Full multi-Deployment Helm tested on kind
- [ ] Thanos Sidecar compose profile
- [ ] Automated screenshot pipeline for `assets/`

## Non-goals

- Proprietary agents; secrets in git; fake metrics as production truth
