# Runbook: FilesystemAlmostFull / FilesystemCritical

## Symptoms
- Free space < 15% (warning) or < 5% (critical).

## Immediate actions
1. `df -h` and `du -xhd1 /path | sort -h`.
2. Clear package caches, old logs, Docker unused data:
   - `journalctl --vacuum-time=7d`
   - `docker system prune -af` (careful in production)
3. Expand volume / LVM / storage if persistent growth.

## Prevention
- Enable retention on Prometheus/Loki.
- Capacity Planning dashboard (33).
