# Alertmanager HA (pair)

Two instances, identical config, gossip `--cluster.peer=...`.
Prometheus lists both `alertmanager-1:9093` and `alertmanager-2:9093`.
See `docker-compose.am-ha.example.yml`.
