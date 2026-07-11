# WireSpot User Manual

WireSpot is an Android hotspot operations app for MikroTik RouterOS routers. It is designed for operators who manage hotspot users, vouchers, reports, and router health while connecting securely through WireGuard VPN.

## Branding And Support

- Product: WireSpot
- Company: Vexel Innovations
- Email: Vexelvision@gmail.com
- Phone: +234(0)7038953065
- Website: https://vexel-innovations.vercel.app/

## First Launch

1. Install the APK on an Android device.
2. Open WireSpot.
3. Create a local PIN.
4. Enable biometric login if the device supports it.
5. Sign in with the PIN after setup.

The PIN is stored as a salted hash. Router passwords and voucher passwords are stored through the secure storage layer, not plain text database fields.

## Recommended Router Setup

Before using RouterOS features:

1. Enable the RouterOS API service on the MikroTik router.
2. Create a dedicated RouterOS user for WireSpot with only the permissions needed for hotspot operations.
3. Use a strong password.
4. Prefer API over WireGuard VPN instead of exposing API ports publicly.
5. Confirm the Android device can reach the router VPN address while WireGuard is connected.

Common RouterOS API ports:

- Plain API: `8728`
- SSL API: `8729`

## Add A Router

1. Go to Dashboard.
2. Open Routers.
3. Tap Add.
4. Enter router name, host, API port, username, and password.
5. Choose SSL if the router API service supports it.
6. Save.
7. Use Test Connection to confirm RouterOS API access.

If Test Connection fails, check VPN status first, then verify host, port, username, password, and RouterOS API service status.

## Dashboard

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

## Hotspot Management

Open Hotspot from the dashboard to manage:

- Users
- Profiles
- Active sessions
- Cookies
- IP bindings
- Queues

Available operations include creating users, creating profiles, disconnecting active sessions, deleting users, resetting counters, and removing hotspot records.

## Voucher Management

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
- Print action boundary
- Optional RouterOS provisioning
- Voucher history

## Reports

Open Reports to view and export:

- Daily revenue
- Weekly revenue
- Monthly revenue
- Sales count
- Voucher history summaries

Export actions currently provide CSV and PDF-text foundations suitable for future polished file export.

## Settings

Settings contains:

- Theme preference
- Language preference
- Notification preference
- Business name
- Printer configuration
- Backup preview
- Restore placeholder
- Sign out

## Printing

WireSpot includes a Bluetooth thermal printer abstraction for 58mm and 80mm receipts. Receipt text includes:

- Business name
- Voucher username/password
- Price
- Validity/time
- QR payload text foundation

The Android platform channel is present. Production Bluetooth printer discovery and vendor-specific ESC/POS handling should be completed in a later implementation step.

## WireGuard VPN

WireSpot expects secure RouterOS access over WireGuard.

The app includes:

- WireGuard config parsing
- Tunnel status abstraction
- Connect/disconnect platform channel
- Tunnel log and statistics models
- Auto-reconnect coordinator
- VPN guard before RouterOS API communication

The current Android WireGuard bridge is a platform foundation. Full official WireGuard backend integration is still a future production task.

## Safe Operating Practice

- Do not expose RouterOS API ports to the public internet.
- Use WireGuard or another private management network.
- Use dedicated RouterOS credentials for WireSpot.
- Rotate credentials if a device is lost.
- Back up settings and voucher history regularly.
- Test voucher generation on a non-critical router before live deployment.

