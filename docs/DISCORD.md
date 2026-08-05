# Discord Notifications

> Manual: [manual/06-exporters-proxmox-notifications.md](manual/06-exporters-proxmox-notifications.md)

## Setup

1. Discord Server → **Settings → Integrations → Webhooks → New Webhook**
2. Copy the webhook URL
3. Put it in `.env`:

```bash
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/....
```

4. Restart Alertmanager / stack:

```bash
docker compose up -d alertmanager
# or full: docker compose up -d
```

## How it works

- Prometheus fires alerts → **Alertmanager**
- Alertmanager routes by severity and uses `alertmanager/templates/discord.tmpl`
- Embeds include severity, instance, summary

## Test

1. Temporarily lower a threshold or use a test alert rule  
2. Watch Alertmanager UI (`:9093`) and the Discord channel  
3. Check logs: `docker compose logs -f alertmanager`

## Related

- Telegram: `TELEGRAM_BOT_TOKEN` + `TELEGRAM_CHAT_ID` in `.env`
- Email: SMTP variables + receivers in `alertmanager/alertmanager.yml`
- [ALERTMANAGER.md](ALERTMANAGER.md)
