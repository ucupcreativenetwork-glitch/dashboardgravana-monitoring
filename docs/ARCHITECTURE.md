# Architecture Decision Records (ADR) — DashboardGravana

## ADR-001: Docker Compose as primary deployment

**Status:** Accepted  
**Context:** Target users range from HomeLab to small enterprise. Many lack Kubernetes expertise.  
**Decision:** Ship a production-hardened Compose stack first. Keep service definitions clean so a future Helm chart can map 1:1.  
**Consequences:** Fast adoption; operators must handle multi-host exporters themselves (file_sd / remote agents). K8s migration is a documented roadmap item.

## ADR-002: Single Prometheus with federation readiness

**Status:** Accepted  
**Context:** HA Prometheus adds operational complexity.  
**Decision:** One Prometheus instance with remote_write receiver enabled and federation job commented as a template.  
**Consequences:** Sufficient for most sites; clear upgrade path when cardinality or retention exceeds a single node.

## ADR-003: Discord as primary notification channel

**Status:** Accepted  
**Context:** Discord is ubiquitous in HomeLab and many SMB ops teams.  
**Decision:** Default receiver is Discord with severity-colored templates. Telegram and Email are optional.  
**Consequences:** Operators without Discord must edit alertmanager.yml.

## ADR-004: Recording rules for dashboard performance

**Status:** Accepted  
**Decision:** Pre-aggregate common ratios in prometheus/recording/.  
**Consequences:** Slightly higher storage; much lower query latency.

## ADR-005: Secrets via environment file

**Status:** Accepted (interim)  
**Decision:** .env + .gitignore for v1. Document migration to secrets managers.  
**Consequences:** Operators must protect the host filesystem and never commit .env.
