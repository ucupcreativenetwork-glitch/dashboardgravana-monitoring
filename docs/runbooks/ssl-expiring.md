# Runbook: SSLCertExpiringSoon / SSLCertExpired

## Symptoms
- Blackbox probe reports certificate expiry < 30 days or already expired.

## Impact
Browsers and API clients will fail TLS handshake after expiry.

## Resolution
1. Identify the certificate path (Nginx, Traefik, Caddy, Cloudflare).
2. Renew via ACME (`certbot renew`) or provider dashboard.
3. Reload the reverse proxy.
4. Confirm with: `echo | openssl s_client -servername HOST -connect HOST:443 2>/dev/null | openssl x509 -noout -dates`
