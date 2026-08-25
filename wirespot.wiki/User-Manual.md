# 📘 User Manual

WireSpot is an Android hotspot operations app for business Wi-Fi and voucher networks. MikroTik RouterOS is the current full live connector. The app also includes a multi-brand foundation for Ruijie/Reyee, OpenWrt, TP-Link Omada, Ubiquiti UniFi, and generic router integrations.

---

## 1. First Launch

1. Install the APK on an Android device.
2. Open WireSpot.
3. Create a local PIN.
4. Enable biometric login if the device supports it.
5. Sign in with the PIN after setup.

> **Security:** The PIN is stored as a salted hash. Router passwords and voucher passwords use the secure storage layer — not plain text database fields.

---

## 2. Recommended Router Setup

Before using MikroTik RouterOS features:

1. Enable the RouterOS API service on the MikroTik router.
2. Create a dedicated RouterOS user for WireSpot with only the permissions needed.
3. Use a strong password.
4. Prefer API over WireGuard VPN instead of exposing API ports publicly.
5. Confirm the Android device can reach the router VPN address while WireGuard is connected.

Common RouterOS API ports:

| Port | Protocol |
|------|----------|
| `8728` | Plain API |
| `8729` | SSL API |

For Ruijie/Reyee, see [[Ruijie Cloud Setup]].

---

## 3. Add a Router

1. Go to **Dashboard** → **Routers** → **Add**.
2. Choose the router brand.
3. Enter router name, host, management port, username, and password.
4. Choose SSL if the router API supports it.
5. Choose the connection mode:
   - **Require WireGuard VPN** → on for remote/VPN routers
   - **Off** → Local LAN use (same network as the router)
6. Save and use **Test Connection** to confirm.

See [[Router Setup and Fleet Management]] for detailed configuration and fleet management.

---

## 4. Dashboard

The dashboard shows the selected router's operating snapshot:

- Online users
- Active sessions
- Today's sales
- CPU load & memory
- Router identity and health
- Interface summary

Tap the **Online users** card to open active hotspot users for the selected router.

---

## 5. Hotspot Management

Open **Hotspot** from the dashboard to manage:

- Users, profiles, active sessions, cookies, IP bindings, queues
- Create, edit, disconnect, delete, and reset counters
- Business setup presets: Quick Voucher, Small Business, Hotel Guest Wi-Fi, RADIUS Managed

See [[Hotspot Management]] for full details.

---

## 6. Voucher Management

Open **Vouchers** to generate hotspot access vouchers:

- Plans: 1 Hour → 30 Days → Unlimited
- Single or batch generation
- Random usernames/passwords, QR payloads
- Receipt preview, share, Bluetooth print
- Optional RouterOS provisioning for MikroTik
- Voucher history

See [[Voucher System]] for full details.

---

## 7. Reports

Open **Reports** to view and export:

- Daily, weekly, monthly revenue
- Sales count and voucher history
- CSV and PDF-text export via Android share sheet

See [[Reports and Export]] for full details.

---

## 8. Settings

| Setting | Details |
|---------|---------|
| Theme | Light/dark preference |
| Language | English, French, Hausa |
| Currency | NGN and common African/global currencies |
| Notifications | Preference control |
| License | Trial status, device license activation |
| VPN | WireGuard configuration |
| Permissions | VPN consent, Bluetooth, camera readiness |
| Co-branding | Business name, email, phone, website, logo |
| Voucher encoding | Username/password mode, lengths, prefixes |
| Ticket templates | 58mm/80mm layout customization |
| Scheduler | Session refresh, cleanup, daily summary |
| Printers | Bluetooth printer pairing |
| Backup | Preview and JSON restore |
| Sign out | App sign-out |

---

## 9. Printing

See [[Printing]] for complete Bluetooth thermal printer setup and receipt formatting.

---

## 10. WireGuard VPN

See [[WireGuard VPN]] for secure remote access configuration, import flows, and troubleshooting.

---

## 11. Licensing

See [[Licensing]] for trial information, device license generation, and subscription plans.

---

## 12. Professional Co-branding

See [[Professional Co-branding]] for operator business identity on receipts and reports.

---

## 13. Safe Operating Practices

- ⚠️ Do **not** expose RouterOS API ports to the public internet.
- 🔒 Use WireGuard or another private management network.
- 🔑 Use dedicated RouterOS credentials with limited permissions.
- 🔄 Rotate passwords if an operator device is lost.
- 💾 Back up settings and voucher history regularly.
- 🧪 Test voucher generation on a non-critical router before live deployment.
