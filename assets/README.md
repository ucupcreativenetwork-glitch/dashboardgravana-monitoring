# Assets

Place public media for the repository and documentation here.

## Suggested layout

```
assets/
├── architecture.png
├── logo.svg
└── screenshots/
    ├── grafana-executive.png
    ├── grafana-proxmox.png
    └── alertmanager-discord.png
```

## Guidelines

- Prefer PNG/WebP for screenshots; SVG for diagrams/logos
- Do not include real hostnames, IPs, or secrets in screenshots
- Keep individual files under ~2 MB
- Reference from README as `![Executive](assets/screenshots/grafana-executive.png)`

Screenshots are optional for CI; `.gitkeep` ensures the directory exists.
