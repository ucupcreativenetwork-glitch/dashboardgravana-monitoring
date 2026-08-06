# Remote write

1. Copy pattern from `prometheus/remote_write.example.yml`
2. Add `remote_write:` to `prometheus.yml`
3. Mount credentials as files (not git)
4. `curl -X POST http://localhost:9090/-/reload`

Drop high-cardinality series before shipping to Mimir/Thanos.
