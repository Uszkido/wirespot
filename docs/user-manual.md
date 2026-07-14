# WireSpot User Manual

WireSpot is an Android hotspot operations app for MikroTik RouterOS routers.
It helps operators manage routers, hotspot users, vouchers, receipts, reports,
and secure remote access from one mobile workflow.

## Branding And Support

- Product: WireSpot
- Company: Vexel Innovations
- Email: Vexelvision@gmail.com
- Phone: +234(0)7038953065
- Website: https://vexel-innovations.vercel.app/

## 1. First Launch

1. Install the APK on an Android device.
2. Open WireSpot.
3. Create a local PIN.
4. Enable biometric login if the device supports it.
5. Sign in with the PIN after setup.

The PIN is stored as a salted hash. Router passwords and voucher passwords are stored through the secure storage layer, not plain text database fields.

## 2. Recommended Router Setup

Before using RouterOS features:

1. Enable the RouterOS API service on the MikroTik router.
2. Create a dedicated RouterOS user for WireSpot with only the permissions needed for hotspot operations.
3. Use a strong password.
4. Prefer API over WireGuard VPN instead of exposing API ports publicly.
5. Confirm the Android device can reach the router VPN address while WireGuard is connected.

Common RouterOS API ports:

- Plain API: `8728`
- SSL API: `8729`

## 3. Add A Router

1. Go to Dashboard.
2. Open Routers.
3. Tap Add.
4. Enter router name, host, API port, username, and password.
5. Choose SSL if the router API service supports it.
6. Choose the connection mode:
   - Keep **Require WireGuard VPN** on for remote/private VPN routers.
   - Turn it off for **Local LAN** use when your phone is on the same network as the MikroTik.
7. Save.
8. Use Test Connection to confirm RouterOS API access.

If Test Connection fails, check the selected connection mode first. VPN routers need WireGuard connected. Local LAN routers need the phone connected to the same network as the MikroTik. Then verify host, port, username, password, and RouterOS API service status.

## 4. Local On-Site Use Without VPN

WireSpot can connect without VPN when the Android device is physically on-site and connected to the same LAN or Wi-Fi as the MikroTik.

For local mode:

1. Add or edit the router.
2. Enter the local router IP, for example `192.168.88.1`.
3. Turn off **Require WireGuard VPN**.
4. Save.
5. Test connection.

Do not use local mode for public internet access. It is intended for same-site management only.

## 5. Dashboard

The dashboard shows the selected router's operating snapshot:

- Online users
- Active sessions
- Today's sales
- CPU load
- Memory
- Router identity and health
- Interface summary
- Vexel Innovations support details

If no router is configured, add a router before expecting live metrics.

Tap the **Online users** dashboard card to open the active hotspot user view
for the selected router.

## 6. Hotspot Management

Open Hotspot from the dashboard to manage:

- Users
- Profiles
- Active sessions
- Cookies
- IP bindings
- Queues

Available operations include creating users, creating profiles, disconnecting active sessions, deleting users, resetting counters, and removing hotspot records.

WireSpot can help set up common hotspot operations by preparing profiles,
users, IP bindings, and voucher batches used by a MikroTik hotspot. Always
review generated setup plans before applying them to a live router.

## 7. Voucher Management

Open Vouchers to generate hotspot access vouchers.

Supported plans include:

- 1 Hour
- 3 Hours
- 6 Hours
- 12 Hours
- 1 Day
- 3 Days
- 7 Days
- 30 Days
- Unlimited

Voucher generation supports:

- Single voucher
- Batch voucher
- Random usernames
- Random passwords
- QR payload generation
- Receipt preview
- Share action
- Bluetooth print action
- Optional RouterOS provisioning
- Voucher history

## 8. Reports

Open Reports to view and export:

- Daily revenue
- Weekly revenue
- Monthly revenue
- Sales count
- Voucher history summaries

Export actions provide share-ready CSV/PDF report output for operator records.

## 9. Settings

Settings contains:

- Theme preference
- Language preference: English, French, and Hausa labels
- Notification preference
- Business name
- Currency preference
- License activation
- Permission readiness
- Professional co-branding
- Voucher encoding
- Printer configuration
- Backup preview
- JSON restore flow
- Sign out

## 10. Printing

WireSpot includes Bluetooth thermal printer support for paired ESC/POS printers using 58mm and 80mm receipts. Receipt text includes:

- Business name
- Voucher username/password
- Price
- Validity/time
- QR payload

To add a printer:

1. Pair the printer in Android Bluetooth settings.
2. Open WireSpot Settings.
3. Tap Add printer.
4. Tap Load paired printers.
5. Select the printer.
6. Choose 58mm or 80mm.
7. Save.

Use paired Bluetooth ESC/POS printers for best results. Test each printer model
before live customer use because some low-cost printers implement ESC/POS
commands differently.

## 11. WireGuard VPN

WireSpot expects secure RouterOS access over WireGuard.

The app includes:

- WireGuard config parsing
- Tunnel status abstraction
- Connect/disconnect platform channel
- Tunnel log and statistics models
- Auto-reconnect coordinator
- VPN guard before RouterOS API communication

The Android build is wired to the official WireGuard tunnel backend. On first
connect, Android may ask for VPN permission. Approve it, then connect again if
the app reports that permission was required.

If the Android permission dialog does not appear, open Settings > Permission
readiness and request VPN consent from there.

## 12. Licensing

WireSpot includes a 7-day full-access trial. After the trial, the app requires
an active license.

For local device-bound licensing:

1. Open Settings.
2. Copy the Device License ID.
3. Generate a license key with the local generator.
4. Paste the key into WireSpot.
5. Tap Apply license.

Each generated local license is bound to the Device License ID used during
generation.

## 13. Professional Co-branding

Professional users can configure operator-facing business details in Settings:

- Business name
- Business email
- Business phone
- Business website

Receipts and reports can show the operator business identity while keeping
WireSpot identified as powered by Vexel Innovations.

## 14. Safe Operating Practice

- Do not expose RouterOS API ports to the public internet.
- Use WireGuard or another private management network.
- Use dedicated RouterOS credentials for WireSpot.
- Rotate credentials if a device is lost.
- Back up settings and voucher history regularly.
- Test voucher generation on a non-critical router before live deployment.
