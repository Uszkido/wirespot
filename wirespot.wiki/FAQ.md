# ❓ FAQ

## General

### What is WireSpot?
WireSpot is a Flutter Android/iOS app for hotspot operators, technicians, and small ISPs who manage business Wi-Fi and voucher networks. It combines router management, hotspot user control, voucher generation, thermal printing, reporting, WireGuard VPN access, and licensing into one mobile app.

### Who makes WireSpot?
WireSpot is built by **Vexel Innovations** in collaboration with **TechNova Technologies**.

### Is WireSpot free?
WireSpot includes a **7-day full-access trial**. After that, a license is required. See [[Licensing]] for details.

### Is WireSpot open source?
WireSpot is **proprietary software** by Vexel Innovations. The source code is hosted on GitHub for development and collaboration. See the [LICENSE](https://github.com/Uszkido/wirespot/blob/main/LICENSE) for terms.

---

## Router Support

### Which routers are supported?
**MikroTik RouterOS** is the current full live connector with complete hotspot management support. WireSpot also has a multi-brand foundation for:

| Brand | Status |
|-------|--------|
| MikroTik | ✅ Full live connector |
| Ruijie / Reyee | ⚡ Cloud connection test |
| OpenWrt | 📋 Planned |
| TP-Link Omada | 📋 Planned |
| Ubiquiti UniFi | 📋 Planned |
| Generic | 📋 Planned |

### Do I need to enable anything on my MikroTik?
Yes — enable the **RouterOS API service** on the router. See [[Router Setup and Fleet Management]].

### Can I manage multiple routers?
Yes! WireSpot supports **fleet management** with multiple routers, groups, concurrent testing, and persistent active-router selection. See [[Router Setup and Fleet Management]].

---

## Remote Access

### Do I need a VPN?
For remote routers, **yes**. WireSpot is designed around WireGuard-first access so you don't expose API ports to the internet. For local/on-site routers, you can use **Local LAN mode** without VPN.

### What VPN protocols are supported?
WireSpot has built-in support for **WireGuard** with config file import and QR scan. It also supports labeling routers as using **MikroTik Back To Home**, **ZeroTier**, **Public API-SSL**, or **Custom/Advanced** access modes.

---

## Vouchers & Printing

### What printer do I need?
Any **Bluetooth thermal printer** that supports ESC/POS over SPP. WireSpot supports **58mm** and **80mm** paper widths. See [[Printing]].

### Can I print QR codes on receipts?
Yes — WireSpot uses native ESC/POS QR commands with paper-width-aware sizing.

### Can I put my business name on receipts?
Yes — see [[Professional Co-branding]] for setting up your business identity.

---

## Platform

### Is there an iOS version?
Not yet. WireSpot is built with Flutter, so iOS is technically possible. The iOS platform folder, native channels, and App Store work are on the roadmap. See [iOS Roadmap](https://github.com/Uszkido/wirespot/blob/main/docs/ios-roadmap.md).

### Is WireSpot on the Play Store?
Not yet. Play Store release preparation is underway, including release signing, privacy policy, and billing integration. See [Play Store Release Guide](https://github.com/Uszkido/wirespot/blob/main/docs/play-store-release.md).

### What languages are supported?
English, French, and Hausa labels are available in **Settings** → **Language**.

---

## Security

### Are my router credentials safe?
Router credentials are stored using **Flutter Secure Storage** boundaries — not in plain text database fields. The PIN is stored as a salted hash.

### Should I expose my router's API port to the internet?
**No.** Use WireGuard or another private management network for remote access. See [[WireGuard VPN]].

---

## Development

### How do I contribute?
See [[Contributing]] for development setup, coding standards, and PR guidelines.

### What's the tech stack?
Flutter, Material 3, Riverpod, GoRouter, Drift/SQLite, and Android platform channels. See [[Architecture Overview]].

### Where can I report bugs?
Open an issue at [github.com/Uszkido/wirespot/issues](https://github.com/Uszkido/wirespot/issues). For security vulnerabilities, use [SECURITY.md](https://github.com/Uszkido/wirespot/blob/main/SECURITY.md).
