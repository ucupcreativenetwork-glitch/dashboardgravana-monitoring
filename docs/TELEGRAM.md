# Telegram Notifications

Production setup for Alertmanager → Telegram.

## 1. Create a bot

1. Open Telegram, talk to [@BotFather](https://t.me/BotFather)
2. `/newbot` → follow prompts → copy the **bot token**
3. Start a chat with your bot (or add it to a group)
4. Get `chat_id`:
   - Private: message the bot, then open  
     `https://api.telegram.org/bot<TOKEN>/getUpdates`  
     → read `message.chat.id`
   - Group: add bot, send a message, same `getUpdates` → negative `chat.id`

## 2. Configure `.env`

```bash
TELEGRAM_BOT_TOKEN=123456789:AA...your_token...
TELEGRAM_CHAT_ID=-1001234567890
```

`TELEGRAM_CHAT_ID` must be numeric (no quotes required in `.env`).

## 3. Render Alertmanager config

Alertmanager **does not** expand environment variables. Always render:

```bash
./scripts/render-alertmanager-config.sh
docker compose up -d alertmanager
```

`install.sh` / `update.sh` call this automatically.

## 4. Routing behaviour

| Receiver | Discord | Telegram | Email |
|----------|---------|----------|-------|
| `default` | ✓ | ✓ | — |
| `warning` | ✓ | — | — |
| `critical` | ✓ | ✓ | ✓ |
| `emergency` | ✓ | ✓ | ✓ |
| `security` | ✓ | ✓ | — |

Warnings stay Discord-only to reduce Telegram noise.

## 5. Test

```bash
curl -X POST http://localhost:9093/api/v2/alerts \
  -H 'Content-Type: application/json' \
  -d '[
    {
      "labels": {
        "alertname": "TelegramTest",
        "severity": "critical",
        "instance": "test"
      },
      "annotations": {
        "summary": "Telegram notification test",
        "description": "If you see this in Telegram, routing works."
      }
    }
  ]'
```

## Security

- Never commit real `TELEGRAM_BOT_TOKEN`
- Restrict bot to the ops group only
- Rotate token if leaked (BotFather → `/revoke`)

## Troubleshooting

| Symptom | Check |
|---------|--------|
| No message | `chat_id` wrong; bot not started / not in group |
| 401 Unauthorized | Token invalid or revoked |
| Config has `${TELEGRAM_…}` | You skipped `render-alertmanager-config.sh` |
| YAML parse error on chat_id | Must be numeric after render (not empty string) |

## Related

- [ALERTMANAGER.md](ALERTMANAGER.md)
- [DISCORD.md](DISCORD.md)
- Template: `alertmanager/templates/telegram.tmpl`
