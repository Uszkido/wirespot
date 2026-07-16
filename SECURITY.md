# Security Policy

WireSpot manages MikroTik RouterOS access, hotspot users, voucher records,
WireGuard tunnels, local authentication, printer workflows, licensing, and
operator business data. Treat security issues with care.

## Supported Versions

| Version | Status |
| --- | --- |
| `0.1.x` | Active development and field testing |
| Older private builds | Best-effort support only |

## Report A Vulnerability

Do not open a public GitHub issue for sensitive reports.

Email security reports to:

```text
Vexelvision@gmail.com
```

Include:

- App version or commit hash.
- Affected area: RouterOS API, WireGuard, authentication, licensing, database,
  printing, reports, Android permissions, backup/restore, or Play Store build.
- Clear reproduction steps.
- Expected and actual behavior.
- Logs with secrets removed.
- Whether the issue affects local LAN mode, WireGuard mode, or both.
- Whether real customer/operator data may be exposed.

## Response Targets

Vexel Innovations aims to:

- Acknowledge high-risk reports within 3 business days.
- Triage reproducible vulnerabilities within 7 business days.
- Provide a fix plan or mitigation when the issue is confirmed.
- Credit reporters when appropriate and requested.

These targets may vary during early private development, but security reports
will be prioritized over normal feature work.

## Do Not Share Publicly

Never post:

- RouterOS passwords or admin usernames.
- WireGuard private keys or full production configs.
- Android keystore files or signing passwords.
- Play Billing secrets or server license-signing keys.
- Real voucher password exports.
- Customer names, phone numbers, payment records, or sales ledgers.
- Screenshots that reveal router IPs, VPN addresses, or credentials.

## Secure Deployment Guidance

- Use WireGuard for remote management.
- Use local LAN mode only on trusted on-site networks.
- Do not expose RouterOS API ports directly to the public internet.
- Use a dedicated RouterOS account for WireSpot with the minimum permissions
  required for hotspot operations.
- Rotate RouterOS credentials if an operator phone is lost or compromised.
- Protect Android devices with screen lock, app PIN, and biometric unlock where
  available.
- Back up Play Store upload keys and license-signing secrets outside the repo.

## Out Of Scope

The following are normally not treated as WireSpot vulnerabilities unless they
demonstrate a direct WireSpot flaw:

- Compromised MikroTik routers caused by weak operator passwords.
- Publicly exposed RouterOS services configured outside WireSpot guidance.
- Rooted or heavily modified Android devices.
- Third-party printer firmware vulnerabilities.
- Social engineering outside WireSpot-controlled channels.

## Security Updates

Confirmed vulnerabilities should be fixed in source first, documented in
`CHANGELOG.md`, and distributed through the next APK/AAB build or urgent patch
build depending on severity.
