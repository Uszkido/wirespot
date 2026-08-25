# 👥 Hotspot Management

## Overview

The Hotspot screen is the daily control center for customer/user operations on your MikroTik RouterOS router.

---

## Hotspot Entities

| Entity | Description |
|--------|-------------|
| **Users** | Hotspot user accounts with credentials, profiles, and limits |
| **Profiles** | User profile templates with speed, session, and data limits |
| **Active Sessions** | Currently connected/authorized hotspot clients |
| **Cookies** | Hotspot session cookies for MAC-authenticated clients |
| **IP Bindings** | Static IP-to-MAC bindings for bypass or block rules |
| **Queues** | Simple queues for bandwidth management |

---

## User Operations

Available MikroTik operations include:

- ✅ **Create** new hotspot users
- ✏️ **Edit** user profile, time, and data fields
- 🔌 **Disconnect** active sessions
- 🗑️ **Delete** users
- 🔄 **Reset** counters
- 🔍 **Search and filter** users

### Advanced User Fields

When creating or editing users, you can configure:

- Username / password (or username-only / PIN-only)
- Profile assignment
- NGN price notes
- Time limit
- Data limit

---

## Hotspot Profiles

Profiles define the rules for hotspot user sessions:

- Upload / download speed limits
- Shared users (concurrent sessions)
- Session timeout
- Idle timeout
- Keepalive timeout
- Price metadata
- Data limit metadata

---

## Hotspot Setup Assistant

WireSpot includes a setup assistant for common business hotspot scenarios. The assistant prepares RouterOS commands and lets you review the plan before applying.

### Available Presets

| Preset | Use Case |
|--------|----------|
| 🎫 **Quick Voucher Hotspot** | Fast voucher-selling setup |
| 🏢 **Small Business Hotspot** | Office/small business Wi-Fi |
| 🏨 **Hotel Guest Wi-Fi** | Guest access with time limits |
| 📡 **RADIUS Managed Hotspot** | External RADIUS authentication |

### What the Setup Prepares

For MikroTik routers, presets prepare:

- Server profiles
- Hotspot servers
- IP pools
- DHCP networks and servers
- NAT masquerade rules

### Important

> ⚠️ **Always review generated setup plans before applying** them to a live router. Field testing on real routers is recommended before using on a production site.

> For Ruijie/Reyee and other brands, presets are planned until the brand connector is implemented.

---

## Scheduler Integration

The scheduler can automate hotspot maintenance:

- **Active session refresh** — Periodically refreshes session data
- **Expired session cleanup** — Disconnects expired active sessions
- **Voucher cleanup** — Removes expired, unused local voucher records

See **Settings** → **Scheduler** to configure intervals and enable tasks.
