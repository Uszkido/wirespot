# WireSpot Payment And Licensing Strategy

This document defines the commercial licensing plan for WireSpot and the path
from local device licenses to production Play Store billing.

## Licensing Goals

WireSpot licensing should be:

- simple for hotspot operators
- fair for small and professional users
- secure enough for paid distribution
- compatible with Play Store rules
- usable for offline/direct enterprise installs
- easy to support from Vexel Innovations

## Access Model

WireSpot uses a full-access trial followed by paid access.

| Stage | Access |
| --- | --- |
| Trial | 7 days of full app access |
| Licensed | Full access for an active plan |
| Expired/unlicensed | App requires license renewal or activation |

## Product Tiers

| Product ID | Plan | Suggested Price | Best For |
| --- | --- | --- | --- |
| `wirespot_small_monthly` | Small monthly | NGN 3,000 - 5,000 | Small hotspot shops, one-site users |
| `wirespot_pro_monthly` | Pro monthly | NGN 8,000 - 12,000 | Active operators, technicians, multi-router users |
| `wirespot_pro_yearly` | Pro yearly | NGN 80,000 - 120,000/year | Serious operators and small ISPs |
| `wirespot_lifetime_device` | Lifetime device | NGN 150,000 - 250,000 | Offline/direct install customers |

## Premium Feature Positioning

Premium/Pro access should include:

- multiple router operations
- WireGuard remote management
- batch vouchers
- advanced voucher encoding
- ticket templates
- professional co-branding
- Bluetooth thermal printing
- reports export
- scheduler tools
- advanced profile/user controls

## Current Active Licensing Features

The app currently supports:

- 7-day trial tracking
- device license ID
- local device-bound license generation
- license key entry in Settings
- entitlement source tracking
- license request copy action

## Production Play Billing Path

For Play Store distribution, paid digital access should use Google Play Billing.

Implementation checklist:

1. Create Play Console subscription products with the product IDs above.
2. Add the official Flutter `in_app_purchase` package.
3. Query products on the license screen.
4. Start purchase from the selected plan.
5. Verify purchase token with a backend.
6. Save verified entitlement with plan and expiry.
7. Restore purchases on startup and from Settings.
8. Handle grace periods, account hold, cancellation, and expiry.

## Server Validation Recommendation

Do not trust phone-side purchase state alone for production.

Recommended validation request:

```text
packageName
productId
purchaseToken
deviceId
accountId or customer reference
appVersion
```

The Vexel server should:

1. Verify the purchase with Google Play Developer API.
2. Confirm the product belongs to WireSpot.
3. Bind entitlement to customer/device policy.
4. Return signed entitlement status and expiry.
5. Reject expired, refunded, or invalid purchases.

## Offline License Path

Offline/device licenses remain useful for:

- customers outside Play Billing availability
- direct APK enterprise installs
- lifetime device deals
- pilots and demos

Each offline license should be bound to one device ID and recorded privately by
Vexel Innovations.

## Support And Renewal Flow

Recommended support flow:

1. Customer opens Settings.
2. Customer copies license request.
3. Customer sends request to Vexel Innovations.
4. Vexel confirms payment or subscription.
5. Vexel issues key or verifies Play Billing entitlement.
6. Customer applies license or restores purchase.

## Contact

Vexel Innovations

Email: Vexelvision@gmail.com

Phone: +234(0)7038953065

Website: https://vexel-innovations.vercel.app/
