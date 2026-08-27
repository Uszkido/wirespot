# ☁️ Cloud Sync

## Mobile app

Open **Settings → Cloud** and save the WireSpot API URL, organization ID, and
session. The mobile app uses a local queue so operations can be retried when
the connection returns.

## Web dashboard

1. Create an account or sign in.
2. Open **Cloud Sync → Cloud Settings**.
3. Enter the deployed backend URL, not the Firebase Firestore REST URL.
4. Save the URL and select **Test**. A healthy server responds from `/health`.
5. Select **Sync Now** to upload vouchers and refresh router inventory.

Protected API requests require `Authorization: Bearer ws_...`. Health and
authentication routes are public.

## Current backend scope

The lightweight backend supports authentication, router inventory, voucher
sync, telemetry, backups, and pending commands. Its current store is
process-local for testing; Firestore persistence and signed production tokens
are required before multi-instance production hosting.
