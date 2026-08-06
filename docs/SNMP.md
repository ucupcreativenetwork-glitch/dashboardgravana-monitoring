# SNMP Monitoring

```bash
docker compose --profile snmp up -d
```

1. Edit `snmp-exporter/snmp.yml` (prefer SNMPv3; never commit real communities).
2. Device IPs in `prometheus/targets/snmp.json` with label `module: if_mib`.
3. Generate vendor modules with upstream snmp-generator for production.

Related: [HOST-EXPORTERS.md](HOST-EXPORTERS.md).
