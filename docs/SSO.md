# SSO

## Reverse-proxy auth (Authelia / Authentik)

```bash
GF_AUTH_PROXY_ENABLED=true
GF_AUTH_PROXY_HEADER_NAME=X-Forwarded-User
GF_AUTH_PROXY_AUTO_SIGN_UP=true
```

Proxy must only set identity headers after successful login.

## Generic OAuth (Keycloak / Authentik)

Configure `GF_AUTH_GENERIC_OAUTH_*` (client id/secret, auth/token/api URLs) and role mapping.

Break-glass: keep local admin password in a vault. HTTPS only. See also [REVERSE-PROXY.md](REVERSE-PROXY.md).
