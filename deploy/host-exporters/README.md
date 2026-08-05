# Host-side exporters

Not part of default Docker Compose. Use with `prometheus/targets/*.json`.

| Exporter | Port | Target file |
|----------|------|-------------|
| windows_exporter | 9182 | windows.json |
| NUT exporter | 9199 | nut.json |
| smartctl_exporter | 9633 | smart.json |
| snmp_exporter | 9116 | snmp.json (device IPs) |

See [docs/HOST-EXPORTERS.md](../../docs/HOST-EXPORTERS.md).
