# Roadmap — DashboardGravana Monitoring

## Done (current main)

- [x] Core stack + 35 dashboards + file_sd + PVE/exporters profiles
- [x] Alertmanager multi-channel (Discord/Telegram/Email)
- [x] CI, backup/restore, reverse-proxy docs
- [x] Windows / NUT / SMART / SNMP target packs + host recipes

## Near term

- [ ] Optional snmp-exporter Compose profile + sample snmp.yml modules
- [ ] Grafana default home dashboard + folder ACLs
- [ ] Alertmanager HA pair example
- [ ] remote_write (Mimir/Thanos) examples
- [ ] Screenshot pipeline for assets/

## Medium term

- [ ] Helm / Kubernetes
- [ ] Ansible multi-node agents
- [ ] SSO (Authelia / Keycloak / Authentik)

## Non-goals

- Proprietary agents; live secrets in git; fake demo metrics as production truth
