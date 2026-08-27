# 🛡️ Licensing

## Overview

WireSpot includes a **7-day full-access trial**. After the trial expires, the app requires an active license to continue operating.

---

## Trial

- Every new installation gets **7 days of full access**.
- All features are available during the trial.
- No credit card required.
- License status is visible in **Settings**.

---

## Device-Bound License

After the trial, activate WireSpot with a local device-bound license key.

### Activation Steps

1. Open **Settings**.
2. Copy the **Device License ID** shown on the phone.
3. Generate a license key on your development machine:

```powershell
dart run tools/license_generator.dart <DEVICE_ID>
```

4. Paste the generated key into WireSpot.
5. Tap **Apply license**.

### Deactivate a device

To remove a local activation from the current phone, open **Settings → Premium
license** and choose **Deactivate this device**, then confirm. This clears the
local device license so the device can be reissued or reassigned. It does not
cancel a Google Play subscription or revoke a server-side entitlement.

### Key Format

License keys follow the format:

```
VEXEL-XXXX-XXXX
```

> **Note:** Each generated license key is bound to the Device License ID used during generation. Legacy `WS-...` keys remain valid.

---

## Entitlement Sources

WireSpot tracks how a user's access was granted:

| Source | Description |
|--------|-------------|
| **Trial** | 7-day automatic trial |
| **Device license** | Local device-bound key |
| **Google Play** | Play Store subscription entitlement |
| **Server license** | Server-validated entitlement |
| **Development** | Dev/testing access |

---

## Planned Subscription Products

| Product ID | Type |
|-----------|------|
| `wirespot_small_monthly` | Monthly small plan |
| `wirespot_pro_monthly` | Monthly pro plan |
| `wirespot_pro_yearly` | Yearly pro plan |
| `wirespot_lifetime_device` | One-time device license |

> Play Billing and server-side license validation are planned for production release. See [payment-and-licensing.md](https://github.com/Uszkido/wirespot/blob/main/docs/payment-and-licensing.md) for the full strategy.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| License doesn't activate | Copy the **exact** Device License ID from Settings |
| Key rejected | Generate a new key with the correct Device ID |
| Extra spaces in key | Paste without leading/trailing spaces |
| Still shows trial | Tap **Apply license** after pasting the key |
