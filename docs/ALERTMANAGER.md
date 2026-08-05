# Alertmanager

Production routing, multi-channel notifications, and config rendering.

> Manual: [manual/05-prometheus-alerting-logging.md](manual/05-prometheus-alerting-logging.md)

## Role

Prometheus evaluates rules → **Alertmanager** groups, inhibits, and routes to:

| Channel | Doc | Env vars |
|---------|-----|----------|
| Discord | [DISCORD.md](DISCORD.md) | `DISCORD_WEBHOOK_URL` |
| Telegram | [TELEGRAM.md](TELEGRAM.md) | `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` |
| Email | this page | `ALERTMANAGER_SMTP_*`, `ALERTMANAGER_EMAIL_TO` |

## Why envsubst / render script

Alertmanager **does not** expand `${ENV}` in YAML.  
Template: `alertmanager/alertmanager.yml.tmpl`  
Rendered: `alertmanager/alertmanager.yml` via:

```bash
./scripts/render-alertmanager-config.sh
```

Called automatically by `scripts/install.sh` and `scripts/update.sh`.

After changing `.env`:

```bash
./scripts/render-alertmanager-config.sh
docker compose up -d alertmanager
```

## Severity model

| Severity | Receiver | Channels | Repeat |
|----------|----------|----------|--------|
| emergency | `emergency` | Discord + Telegram + Email | 15m |
| critical | `critical` | Discord + Telegram + Email | 1h |
| warning | `warning` | Discord | 6h |
| (default) | `default` | Discord + Telegram | 4h |

Inhibition reduces noise (critical suppresses warning for same alert/instance; `NodeDown` suppresses other alerts on that instance).

## Email (SMTP)

```bash
ALERTMANAGER_SMTP_SMARTHOST=smtp.example.com:587
ALERTMANAGER_SMTP_FROM=alertmanager@example.com
ALERTMANAGER_SMTP_AUTH_USERNAME=alertmanager@example.com
ALERTMANAGER_SMTP_AUTH_PASSWORD=app-password
ALERTMANAGER_SMTP_REQUIRE_TLS=true
ALERTMANAGER_EMAIL_TO=oncall@example.com
```

Then render + restart. HTML body uses `alertmanager/templates/email.tmpl`.

## UI

http://localhost:9093 — alerts, silences, status.

## Test notification

```bash
curl -X POST http://localhost:9093/api/v2/alerts \
  -H 'Content-Type: application/json' \
  -d '[{
    "labels": {"alertname":"ConfigTest","severity":"warning","instance":"test"},
    "annotations": {"summary":"AM test","description":"Routing check"}
  }]'
```

## Related

- [DISCORD.md](DISCORD.md)
- [TELEGRAM.md](TELEGRAM.md)
- [runbooks/](runbooks/)
