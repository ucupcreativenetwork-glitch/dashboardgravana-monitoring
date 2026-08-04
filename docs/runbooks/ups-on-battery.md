# Runbook: UPSOnBattery / UPSBatteryLow

## Symptoms
- UPS reports on battery or charge < 30%.

## Actions
1. Verify mains power and PDU.
2. Estimate runtime from UPS load metrics.
3. Gracefully shut down non-critical workloads if runtime is short.
4. After power restored, confirm UPS returns to OL (online).
