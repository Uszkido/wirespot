# WireSpot Technical Manual

**Product:** WireSpot hotspot operations platform  
**Publisher:** Vexel Innovations, in collaboration with TechNova Technologies  
**Release:** 1.0.3+34  
**Audience:** hotspot operators, field technicians, small ISPs, hotels, estates, and support teams

## 1. What WireSpot is

WireSpot brings router management, hotspot operations, vouchers, sales reports,
printing, secure remote access, and cloud synchronization into one workspace.
The Android application remains useful on a local network when the internet is
unavailable. The hosted dashboard gives an authorized team a shared view of the
same organization.

The current full live router connector is MikroTik RouterOS. Other vendors have
safe connection or discovery foundations, but WireSpot deliberately refuses to
invent CPU, memory, interface, hotspot, or command results where a vendor API
mapping is not yet complete.

## 2. Before you start

Prepare:

- An Android phone for the first installation and field work.
- A MikroTik router running RouterOS with API access enabled.
- A local LAN connection, or a private tunnel such as WireGuard, Back To Home,
  or ZeroTier for remote management.
- An organization account and the same organization ID on each paired device.
- Optional: a Bluetooth ESC/POS printer, FreeRADIUS host, and a cloud API URL.

For remote production use, do not expose RouterOS management ports directly to
the public internet. Use a private tunnel and firewall rules.

## 3. Install and secure the mobile app

1. Install the signed APK supplied by the organization or install the debug APK
   during field testing.
2. On first launch, create a local PIN. This PIN protects the device and is not
   the cloud access token.
3. Enable fingerprint, face, iris, Touch ID, Face ID, or Windows Hello when the
   platform offers it. The PIN remains the recovery fallback.
4. Follow the first-run walkthrough. It can be replayed from Settings.
5. Choose a theme, language, currency, and business identity.

The app stores router credentials in secure platform storage and scopes cloud
router secrets by organization and router ID. Never paste a router password or
operator token into a public issue, screenshot, or source file.

## 4. Add the first MikroTik router

On the router, check the API service:

```routeros
/ip service print where name~"api"
/ip service enable api
```

Use API-SSL (`8729`) only after certificates and firewall rules are configured.
The standard API port is normally `8728`.

In WireSpot:

1. Open **Routers** and choose **Add router**.
2. Select **MikroTik RouterOS**.
3. Enter a clear name, host/IP, API port, username, and password.
4. Select the access mode: **Local LAN**, **WireGuard**, **Back To Home**,
   **ZeroTier**, or another approved private path.
5. Save, then run **Test connection**.
6. Open the router card to inspect identity, health, interfaces, users, and
   available actions.

If the router is remote, connect the tunnel before testing the RouterOS API.
Local LAN mode is appropriate when the phone and router are on the same network.

## 5. Remote access and VPNs

WireGuard is the preferred private management path. Import a configuration file
or scan its QR code from **Settings > WireGuard VPN**, approve the Android VPN
permission, connect, and then test the router.

The app can store multiple profiles, but Android and iOS normally permit one
active full-device VPN tunnel at a time. Use one profile with multiple peers
when several router networks must be reachable simultaneously. A VPN provides
the management path; it does not replace PPPoE subscriber authentication.

Back To Home and ZeroTier can be recorded as access modes when they provide the
private route to the router. Public API-SSL is an advanced option and must be
restricted by RouterOS firewall rules and trusted source addresses.

## 6. Cloud account and synchronization

The hosted dashboard is available at `https://wirespot.web.app/`. The reference
API is `https://wirespot-api.onrender.com`.

1. Create an account or sign in on the dashboard.
2. In **Cloud Sync**, enter the API base URL and organization ID supplied by
   your administrator.
3. Sign in or pair the mobile device with the one-time pairing code shown in the
   activated phone's cloud session.
4. Test the connection, then choose **Sync now**.

The mobile app uploads organization-scoped router inventory, vouchers, settings,
reports, printers, VPN profiles, groups, and telemetry frames. The dashboard
hydrates its cards from the authenticated API and merges router inventory from
multiple devices instead of replacing a fleet with the last writer. Changes made
offline stay in the local queue and are retried after connectivity returns.

The web and mobile clients must use the same organization ID. A successful
`/health` request only proves that the API is reachable; it does not prove that
the account is authenticated or that a router is online.

### Production backend note

The hosted reference service currently reports development-token mode until its
operator config is changed. A production deployment must set:

- `WIRESPOT_ENV=production` (or `WIRESPOT_PRODUCTION=true`)
- `WIRESPOT_OPERATOR_TOKENS` with server-owned entries in the form
  `token|organizationId|role`
- `WIRESPOT_STORE_PATH` on persistent storage, or replace the JSON store with a
  managed database/Firestore implementation

Development login tokens are not production credentials. Free sleeping hosts are
fine for pilots but do not guarantee uptime or durable storage.

## 7. Hotspot, subscribers, PPPoE, and RADIUS

The MikroTik hotspot screens manage users, profiles, active sessions, queues,
cookies, IP bindings, disconnects, counters, and deletion. Voucher generation
supports batches, PIN-style credentials, QR payloads, plans, prices, and expiry.

For PPPoE subscriber access, deploy the bundled FreeRADIUS service on a private
host. Configure RouterOS with the RADIUS address, UDP ports `1812` and `1813`,
and a strong shared secret. PPPoE/RADIUS authenticates subscribers and records
accounting; it is separate from the secure cloud management path. Do not expose
RADIUS UDP ports to the public internet.

The starter RADIUS policy is suitable for a lab. Production deployments should
move subscriber data to SQL or a protected REST-backed policy service.

## 8. Reports, vouchers, and printing

Reports support daily, weekly, and monthly views with revenue and sales detail.
Export CSV for spreadsheets, PDF for sharing or filing, and JSON for backups or
integration. Voucher receipts support QR codes, co-branding, and 58 mm or 80 mm
ESC/POS layouts.

To print, pair the Bluetooth printer in the operating system, add it under
**Settings > Printers**, choose the paper width, and print a preview receipt.
Real printer testing is required because ESC/POS support differs by model.

## 9. Roles and safe operations

Organizations use owner, admin, manager, operator, and viewer roles. The server
checks organization and role claims; the app also hides or disables actions that
the current role cannot perform. Treat the viewer role as read-only.

High-impact operations such as router commands, reboots, backup restore, and
license administration require an appropriate role. Review the target router and
command before confirming. Keep tokens, pairing codes, and credentials private.

## 10. Vendor support status

| Vendor | Current support |
| --- | --- |
| MikroTik RouterOS | Live connection, snapshots, hotspot/voucher operations, and command execution |
| Ruijie / Reyee | Authenticated Ruijie Cloud connection check and device discovery |
| OpenWrt | Authenticated read-only ubus dashboard snapshot; mutations pending |
| TP-Link Omada | Authenticated controller probe foundation; normalized mutations and snapshots pending |
| Ubiquiti UniFi | Authenticated controller probe foundation; normalized mutations and snapshots pending |
| Generic | Connection/probe foundation only |

Unsupported vendor commands and snapshots fail clearly. They are not replaced by
made-up telemetry. Use the vendor's own controller until a tested WireSpot
adapter is released.

## 11. Windows, Linux, and iOS

Windows and Linux use the Flutter desktop application and share the cloud and
local workflows. Windows can use WireGuard for Windows, Windows printer queues,
and Windows Hello where installed. Distribute the complete release folder, not
only the executable, because Flutter DLLs and data files are required.

The iOS target requires Apple signing and a macOS/Xcode workflow for a real
device or TestFlight. Unsigned CI output is for build validation only. Native
WireGuard, Bluetooth printing, and biometric behavior must be verified on an
iPhone before release.

Companion devices use the same organization subscription. A desktop can be
paired to an activated phone with a one-time pairing code instead of requiring a
second subscription; device limits and entitlement policy remain server-owned.

## 12. Troubleshooting

**Cloud backup returns 404.** Confirm the API base URL, organization ID, and
authenticated session. A healthy API does not imply that a backup exists yet.

**The dashboard shows a router offline.** Refresh the dashboard, verify that the
mobile agent is authenticated for the same organization, check the router's
local/VPN path, and run Test connection. Telemetry is only marked live when a
real connector has delivered a recent snapshot.

**A non-MikroTik command is rejected.** This is intentional until that vendor's
command mapping is implemented and tested. Use the vendor controller.

**The Android APK reports `libsqlite3.so` missing.** Install a current artifact
from the CI build after the native SQLite library bundling fix; do not reuse an
older APK cached on the phone.

**Cloud sync appears empty.** Check that both devices use the same organization
ID and account, then run Sync now. Inspect pending operations and the last sync
time before retrying.

**Router ping fails.** Ping tests the management path, not just internet access.
Confirm the tunnel is connected, the host/port is reachable from that tunnel,
RouterOS API is enabled, and the credentials have the required policy.

## 13. Support and release checklist

Before a field rollout:

1. Run `flutter analyze` and `flutter test`.
2. Test a real MikroTik on LAN and through the chosen VPN path.
3. Create a voucher, print a receipt, export a CSV/PDF, and restore a backup.
4. Verify the same organization appears on mobile and web.
5. Confirm role restrictions with an operator and viewer account.
6. Confirm production backend configuration and persistent storage.
7. Record the deployed app version and keep a rollback APK.

This manual is intended to be self-contained. If support is needed, use the
contact details in the app's About page and include the app version, device,
router vendor, connection mode, and the exact error message. Never include
passwords, access tokens, pairing codes, or customer data in a support request.

## 14. Product identity

WireSpot is a Vexel Innovations product developed in collaboration with
TechNova Technologies. Product support, licensing, and release information
should use the approved contact details shown in the app's About page and the
organization's published support channel.

## 15. Quick reference and glossary

**API Base URL:** The HTTPS address of the WireSpot cloud service. It is not the
router address and should never be replaced with a private RouterOS IP.

**Organization ID:** The workspace identifier shared by the mobile app and web
dashboard. Devices using different organization IDs cannot see one another's
routers, vouchers, or reports.

**Access token:** A secret bearer credential used for cloud API requests. It is
created by the configured sign-in or pairing flow and should be treated like a
password. It is not the local PIN, RouterOS password, or RADIUS secret.

**Pairing code:** A short-lived, one-time code displayed by an activated device
to authorize a companion desktop or web session.

**Telemetry:** A time-stamped observation obtained from a real router connector.
When a connector cannot provide a value, WireSpot leaves it unavailable rather
than displaying a guessed number.

**RouterOS API:** MikroTik's management protocol. Port `8728` is the usual
plain API port; `8729` is the usual API-SSL port.

**RADIUS:** The authentication and accounting service used for subscriber
access such as PPPoE. RADIUS is not a VPN and does not make a router remotely
reachable by itself.

**VPN management path:** A private route, such as WireGuard, Back To Home, or
ZeroTier, through which the app can reach a router without publishing its
management port.

### Daily operator checklist

1. Confirm the correct organization and current sync time.
2. Check that the active router has a recent real snapshot.
3. Review active sessions and sales before issuing vouchers.
4. Export or back up important records before major configuration changes.
5. Disconnect the VPN when field work is complete if it is not needed.
6. Sign out of shared computers and never leave tokens in screenshots.
