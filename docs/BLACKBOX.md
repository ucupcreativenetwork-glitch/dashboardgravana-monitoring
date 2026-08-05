# Blackbox Exporter & File SD Targets

Production guide for synthetic probes in DashboardGravana.

## Architecture

```
Prometheus ──(file_sd)──► targets/*.json
     │
     └── /probe?module=…&target=… ──► blackbox-exporter:9115
                                            │
                                            ├── http_2xx / http_2xx_ssl
                                            ├── icmp
                                            ├── tcp_connect
                                            ├── tls_connect  (SSL cert metrics)
                                            └── dns_a
```

**Why file_sd instead of static_configs**

| Approach | Restart needed | Multi-node | Ansible-friendly |
|----------|----------------|------------|------------------|
| static_configs in prometheus.yml | Yes | Painful | No |
| file_sd JSON | No (30s refresh) | Yes | Yes |

## Modules (blackbox.yml)

| Module | Prober | Use case |
|--------|--------|----------|
| `http_2xx` | HTTP | Generic health (HTTP or HTTPS) |
| `http_2xx_ssl` | HTTP | Force TLS (fail if plain HTTP) |
| `http_2xx_insecure` | HTTP | Lab / internal self-signed |
| `tcp_connect` | TCP | Port open (SSH, DB, DNS) |
| `tls_connect` | TCP+TLS | Certificate expiry + handshake |
| `icmp` | ICMP | Reachability (needs `NET_RAW`) |
| `dns_a` | DNS | Resolver + A record |

## Target files

Located at `prometheus/targets/`:

- `nodes.json` — Node Exporter hosts
- `blackbox-http.json` — HTTP/HTTPS URLs
- `blackbox-icmp.json` — IP / hostname for ping
- `blackbox-tcp.json` — `host:port`
- `blackbox-ssl.json` — `host:443` for cert checks
- `blackbox-dns.json` — DNS server addresses

See `prometheus/targets/README.md` for JSON schema and examples.

## Add a public website probe

1. Edit `prometheus/targets/blackbox-http.json`.
2. Wait ≤30s or reload: `curl -X POST http://localhost:9090/-/reload`
3. Verify in Prometheus → Status → Targets → `blackbox-http`.
4. Grafana dashboards **13-Internet** and **22-SSL** pick up metrics automatically.

## SSL certificate monitoring

Targets in `blackbox-ssl.json` use module `tls_connect`.

Key metrics:

- `probe_success`
- `probe_ssl_earliest_cert_expiry` (unix timestamp)
- `probe_duration_seconds`

Days until expiry (PromQL):

```promql
(probe_ssl_earliest_cert_expiry - time()) / 86400
```

## ICMP notes

- Container has `cap_add: [NET_RAW]` in `docker-compose.yml`.
- Test with debug URL on blackbox-exporter.

## Security

- Do not expose Blackbox or Node Exporter to the public internet.
- Never put credentials in target labels or JSON files committed to git.

## Troubleshooting

| Symptom | Check |
|---------|--------|
| Target missing | JSON syntax; file mounted at `/etc/prometheus/targets` |
| `blackbox-http` down | blackbox-exporter healthy; module name matches |
| ICMP always fail | `cap_add: NET_RAW`; host firewall; try TCP instead |
| SSL metrics empty | Use `host:443` not `https://…` for `tls_connect` |
| Stale targets | `curl -X POST …/-/reload` or restart Prometheus |

```bash
for f in prometheus/targets/*.json; do
  python3 -m json.tool "$f" >/dev/null && echo "OK $f" || echo "FAIL $f"
done

curl -s http://localhost:9090/api/v1/targets \
  | jq -r '.data.activeTargets[] | "\(.labels.job)\t\(.labels.instance)\t\(.health)"'
```

## Related dashboards

- **13 — Internet / Probes**
- **22 — SSL Certificates**
- **11 — Network**
- **20 — Alert Center**
