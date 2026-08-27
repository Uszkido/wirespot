# 🌐 WireSpot

**Secure multi-brand hotspot operations built by [Vexel Innovations](https://vexel-innovations.vercel.app/) in collaboration with TechNova Technologies.**

WireSpot is a modern Flutter Android/iOS application for hotspot operators, technicians, and small ISPs who manage business Wi-Fi and voucher networks. It brings router management, hotspot users, voucher generation, thermal printing, reporting, WireGuard remote access, backup, and licensing into one mobile app.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🔌 **Router Management** | MikroTik RouterOS live connector + multi-brand foundation (Ruijie/Reyee, OpenWrt, TP-Link Omada, Ubiquiti UniFi, generic) |
| 👥 **Hotspot Operations** | Users, profiles, sessions, cookies, IP bindings, queues, disconnect, reset, delete |
| 🎫 **Voucher System** | Single/batch generation, QR codes, PIN-style, random credentials, receipt preview |
| 🖨️ **Thermal Printing** | Bluetooth ESC/POS 58mm/80mm receipts with logo and native QR |
| 📊 **Reports & Export** | Daily/weekly/monthly revenue, CSV and PDF export via Android share sheet |
| 🔒 **WireGuard VPN** | Secure remote router access — no exposed API ports |
| 🏢 **Co-branding** | Operator business identity on receipts and reports |
| 🛡️ **Security** | PIN + biometric login, encrypted storage, device-bound licensing |
| 🌍 **Multi-language** | English, French, and Hausa labels |
| 📡 **Fleet Management** | Multiple routers, groups, concurrent testing, persistent active-router |

---

## 📖 Wiki Navigation

### Getting Started
- [[Getting Started]] — Requirements, installation, and first launch
- [[Architecture Overview]] — Tech stack, code structure, and design patterns

### Core Features
- [[User Manual]] — Complete end-to-end operator guide
- [[Router Setup and Fleet Management]] — Adding routers, access modes, fleet ops
- [[Hotspot Management]] — Users, profiles, sessions, and setup presets
- [[Voucher System]] — Generation, encoding, QR, and printing
- [[WireGuard VPN]] — Secure remote access configuration
- [[Cloud Sync]] — Mobile/web cloud connection and synchronization

### Tools & Output
- [[Printing]] — Bluetooth thermal printer setup and receipt formatting
- [[Reports and Export]] — Revenue tracking and file export

### Configuration
- [[Licensing]] — Trial, device licenses, and subscription plans
- [[Professional Co-branding]] — Operator business identity
- [[Ruijie Cloud Setup]] — Ruijie/Reyee cloud connection guide

### Reference
- [[Troubleshooting]] — Diagnostics for routers, VPN, printers, and builds
- [[Contributing]] — Development setup, branch style, and PR checklist
- [[FAQ]] — Frequently asked questions

---

## 🏷️ Brand & Support

| | |
|---|---|
| **Product** | WireSpot |
| **Company** | Vexel Innovations |
| **Collaboration** | TechNova Technologies |
| **Email** | Vexelvision@gmail.com |
| **Website** | [vexel-innovations.vercel.app](https://vexel-innovations.vercel.app/) |

---

> **Disclaimer:** WireSpot is in active development and field testing. Test on non-critical routers before production deployment, keep router backups, and use private management paths such as WireGuard instead of exposing management ports publicly.
