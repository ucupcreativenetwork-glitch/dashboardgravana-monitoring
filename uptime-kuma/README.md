# Uptime Kuma

Uptime Kuma runs as a service in `docker-compose.yml` (default port **3001**).

- Data is stored in a **Docker named volume** (not this directory).
- First visit: open http://localhost:3001 and complete the setup wizard.
- Use it for status pages and complementary synthetic checks alongside Prometheus Blackbox.

No static config file is required in-repo; configuration is done in the Kuma UI.
