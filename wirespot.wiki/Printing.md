# 🖨️ Printing

## Overview

WireSpot supports Bluetooth thermal printer output for voucher receipts using the ESC/POS command protocol. Receipts include business branding, voucher credentials, price, validity, QR codes, and operator co-branding.

---

## Supported Printers

| Feature | Details |
|---------|---------|
| **Connection** | Bluetooth SPP (Serial Port Profile) |
| **Protocol** | ESC/POS text commands |
| **Paper widths** | 58mm and 80mm |
| **UUID** | Standard serial profile `00001101-0000-1000-8000-00805F9B34FB` |

---

## Printer Setup

### Step-by-Step

1. **Pair the printer** in Android Bluetooth settings first.
2. Open **WireSpot** → **Settings** → **Add printer**.
3. Tap **Load paired printers**.
4. Approve Bluetooth permission if Android asks.
5. **Select** the printer from the list.
6. Choose **58mm** or **80mm** paper width.
7. **Save**.

---

## Receipt Content

Each printed receipt includes:

- 🏢 Business name (from co-branding settings)
- 🖼️ Logo (raster ESC/POS image from Vexel logo or operator logo)
- 👤 Voucher username / password
- 💰 Price
- ⏱️ Validity / time limit
- 📱 QR code payload (native ESC/POS QR commands)
- 📝 Template footer text

---

## Receipt Formatting

### Logo Printing

WireSpot prints a raster logo before the receipt text:
- Paper-width-aware scaling (58mm vs 80mm)
- Falls back to text-only output if raster printing fails

### QR Code Printing

Native ESC/POS QR commands with:
- Paper-width-aware QR sizing
- Text fallback payload below the QR block

### Text Formatting

- ESC/POS text alignment (center, left)
- Bold headers
- Word-wrapped QR payloads and long lines for narrow printers

---

## Ticket Templates

Customize receipt layout in **Settings** → **Ticket templates**:

| Field | Description |
|-------|-------------|
| Paper width | 58mm or 80mm |
| Logo marker | Include/exclude logo |
| QR | Include/exclude QR code |
| Price | Show/hide price |
| Footer | Custom footer text |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Printer not appearing | Pair it in Android Bluetooth settings first |
| Print fails | Confirm printer is powered on and not connected to another app |
| Garbled output | Try switching between 58mm and 80mm settings |
| No Bluetooth permission | Approve the permission prompt, then retry |
| Logo not printing | Some cheap printers don't support raster images — text still prints |

> **Tip:** Test each printer model before live customer use. Some low-cost printers implement ESC/POS commands differently.
