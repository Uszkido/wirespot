# WireSpot Payment and Licensing Plan

WireSpot will use a 7-day full-access trial. After the trial ends, the app
requires an active entitlement before hotspot tools, routers, reports,
printing, scheduler, and WireGuard management remain usable.

## Recommended Products

Use Google Play subscriptions for Play Store installs:

| Product ID | Plan | Suggested price |
| --- | --- | --- |
| `wirespot_small_monthly` | Small monthly | NGN 3,000 - 5,000 |
| `wirespot_pro_monthly` | Pro monthly | NGN 8,000 - 12,000 |
| `wirespot_pro_yearly` | Pro yearly | NGN 80,000 - 120,000/year |

Use device-bound offline licenses for direct installs, enterprise customers,
and operators that cannot use Play Store billing:

| Product ID | Plan | Suggested price |
| --- | --- | --- |
| `wirespot_lifetime_device` | Lifetime device | NGN 150,000 - 250,000 |

## Entitlement Sources

The app now tracks where access came from:

- Trial: first 7 days on the device.
- Device license: generated from the WireSpot device ID.
- Google Play: future Play Billing purchase or subscription restore.
- Server license: future Vexel license server validation.
- Development: local test override keys only.

## Play Billing Implementation Checklist

1. Create the subscription products in Google Play Console using the product
   IDs above.
2. Add the official Flutter `in_app_purchase` package.
3. Query products on the license screen.
4. Start purchase flow from the selected plan.
5. Verify purchases with a backend before granting long-term access.
6. Call `EntitlementService.savePlayBillingEntitlement` only after a purchase
   token is verified.
7. Restore purchases on startup and from Settings.

## Server Validation Recommendation

For production, do not trust purchase state from the phone alone. Send the
purchase token, package name, product ID, device ID, and account ID to a Vexel
server. The server should validate the purchase with Google Play Developer API,
then return a signed entitlement expiry.

## Offline License Generation

Offline licenses remain useful for direct APK installs and enterprise deals.
Each generated key is bound to one WireSpot device ID, so the customer must
send their device license ID from Settings before a key is generated.
