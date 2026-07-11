# Security Policy

WireSpot manages RouterOS access, hotspot users, vouchers, VPN state, local
PIN authentication, and printer workflows. Treat security issues seriously.

## Supported Version

| Version | Status |
| --- | --- |
| 0.1.x | Active development |

## Report A Vulnerability

Do not open a public GitHub issue for sensitive reports.

Email:

```text
Vexelvision@gmail.com
```

Include:

- A short description of the issue.
- Affected app version or commit hash.
- Steps to reproduce.
- Logs with secrets removed.
- Whether RouterOS, WireGuard, Android, database, printer, or voucher flows are
  involved.

## Sensitive Data Rules

Never share:

- RouterOS passwords.
- WireGuard private keys.
- Voucher password exports from real deployments.
- Customer phone numbers or payment records.
- Android keystore files.
- Release signing keys.

## Deployment Security

- Prefer WireGuard for remote management.
- Local LAN mode is only for trusted on-site networks.
- Do not expose RouterOS API ports to the public internet.
- Use dedicated RouterOS credentials with limited permissions.
- Rotate router credentials if an operator device is lost.

