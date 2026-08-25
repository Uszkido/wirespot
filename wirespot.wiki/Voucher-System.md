# 🎫 Voucher System

## Overview

WireSpot's voucher system lets you generate, manage, and distribute hotspot access vouchers with full control over credentials, time limits, pricing, QR codes, and receipt output.

---

## Voucher Plans

| Plan | Duration |
|------|----------|
| 1 Hour | 60 minutes |
| 3 Hours | 180 minutes |
| 6 Hours | 360 minutes |
| 12 Hours | 720 minutes |
| 1 Day | 24 hours |
| 3 Days | 72 hours |
| 7 Days | 1 week |
| 30 Days | 1 month |
| Unlimited | No time limit |

---

## Generation Modes

### Single Voucher
Generate one voucher at a time with full control over all fields.

### Batch Voucher *(Premium)*
Generate multiple vouchers in one operation with consistent settings.

---

## Credential Modes

WireSpot supports multiple username/password generation styles:

| Mode | Output |
|------|--------|
| **Username + Password** | Random username and password pair |
| **Username Only** | Random username, no password |
| **Username as PIN** | Single numeric/alphanumeric PIN code |

---

## Voucher Encoding Settings

Configure encoding in **Settings** → **Voucher encoding**:

| Setting | Options |
|---------|---------|
| Mode | Username+password, username-only, PIN |
| Character type | Numeric, alphabetic, alphanumeric |
| Username length | Configurable range |
| Password length | Configurable range |
| Prefix | Custom prefix for generated codes |
| Avoid confusing chars | Skip ambiguous characters (0/O, 1/l) |

---

## QR Code Payloads

Each voucher can include a QR payload containing the credentials. QR codes appear in:

- Receipt preview
- Share output
- Printed receipts (native ESC/POS QR commands)

---

## Voucher Workflow

```
Generate → Preview → Share / Print → (Optional) Provision on RouterOS
```

1. **Generate** — Create voucher(s) with plan, profile, price, and credentials.
2. **Preview** — Review the receipt with business branding, QR, and details.
3. **Share** — Send via Android share sheet (WhatsApp, email, etc.).
4. **Print** — Print on a paired Bluetooth thermal printer (see [[Printing]]).
5. **Provision** — Optionally create the hotspot user on the MikroTik router.

---

## Advanced Voucher Fields

| Field | Description |
|-------|-------------|
| Price | Amount in selected currency (e.g., NGN) |
| Data limit | Maximum data usage |
| Profile | Hotspot user profile to assign |
| Quantity | Number of vouchers (batch mode) |
| Prefix | Code prefix for organization |
| Username/password length | Character count ranges |

---

## Voucher History

All generated vouchers are stored locally with:

- Generation timestamp
- Credentials (encrypted)
- Plan and profile details
- Price and data limits
- Print/share status

---

## RouterOS Provisioning

For MikroTik routers, WireSpot can optionally provision the generated voucher as a real hotspot user on the router. This creates the user record with the correct profile, credentials, and limits.

> ⚠️ Ensure the selected profile exists on the router before provisioning.
