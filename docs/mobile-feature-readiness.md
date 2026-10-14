# Mobile feature readiness

The Flutter app is release-buildable and its local feature suite is covered by
the CI pipeline. MikroTik RouterOS is the production management path for
hotspot setup, vouchers, sessions, reports, VPN, cloud sync, and RADIUS.

## Connector status

| Area | Status |
| --- | --- |
| MikroTik RouterOS API | Live connector; requires a reachable router and secure credentials. |
| RADIUS / FreeRADIUS | Live RouterOS provisioning flow; the external RADIUS server must already be reachable. |
| Ruijie, OpenWrt, Omada, UniFi | Connection/controller scaffolding exists, but hotspot mutations still require vendor-specific API verification before production use. |
| Generic router | Capability adapter only; no universal hotspot API exists. |

The app must not be considered hardware-verified from unit tests alone. Before
shipping a non-MikroTik connector, run its connection test and verify create,
read, update, delete, and reconnect behavior against that vendor's controller.
