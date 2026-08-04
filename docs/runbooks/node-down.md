# Runbook: NodeDown

## Symptoms
- Alert `NodeDown` firing
- Node Exporter target unreachable for >2 minutes

## Impact
Host metrics stop; dependent alerts may also fire. Workloads on the node may be down.

## Triage
1. Ping the host IP / hostname.
2. SSH to the host (or console via Proxmox/IPMI).
3. Check `systemctl status node_exporter` or Docker container if agent is containerized.
4. Check firewall (port 9100/tcp from Prometheus).
5. Review recent maintenance / reboot windows.

## Resolution
- Restore host power / network.
- Restart node_exporter: `systemctl restart node_exporter` or `docker compose restart node-exporter`.
- Confirm target is `UP` in Prometheus → Status → Targets.

## Escalation
If hardware failure: open datacenter ticket, migrate VMs if Proxmox cluster.
