# Host Exporters — Windows, NUT, SMART, SNMP

Metrics that need Windows, UPS devices, disks, or SNMP stay **outside** the default Compose stack. Prometheus discovers them via **file_sd**.

| Target file | Job | Port | Dashboard |
|-------------|-----|------|-----------|
| `windows.json` | `windows-exporter` | 9182 | Host / Windows |
| `nut.json` | `nut-exporter` | 9199 | **26-UPS** |
| `smart.json` | `smartctl` | 9633 | **28-SMART** |
| `snmp.json` | `snmp` | device → snmp-exporter | **24/25** |

## Windows

1. Install [windows_exporter](https://github.com/prometheus-community/windows_exporter/releases) MSI with collectors (`cpu,cs,logical_disk,net,os,system,service,memory`).
2. Firewall: allow TCP **9182** only from the monitoring server.
3. Edit `prometheus/targets/windows.json` → `host:9182`.
4. Reload Prometheus if needed: `curl -X POST http://localhost:9090/-/reload`.

## NUT (UPS)

```
UPS → nut-server → nut_exporter:9199 → Prometheus
```

Install `nut` on the UPS host, run exporter (see `deploy/host-exporters/nut-exporter.service`), point `nut.json` at `host:9199`.

## SMART

Install [smartctl_exporter](https://github.com/prometheus-community/smartctl_exporter) on the storage host (device access). Sample unit: `deploy/host-exporters/smartctl-exporter.service`. Target port **9633**.

## SNMP

Run [snmp_exporter](https://github.com/prometheus-community/snmp_exporter). `snmp.json` lists **device IPs**; scrape job rewrites to `snmp-exporter:9116`. Credentials only in snmp_exporter config, never in target labels.

## Security

- Scope firewall to monitoring server only
- Do not publish 9182/9199/9633/9116 publicly
- Prefer SNMP v3

## Related

- [EXPORTERS.md](EXPORTERS.md) · [BLACKBOX.md](BLACKBOX.md) · `deploy/host-exporters/`
