# ☁️ Ruijie Cloud Setup

WireSpot can verify a Ruijie/Reyee cloud connection using Ruijie Cloud's device-list API. This is an **early, read-only integration**: it confirms that WireSpot can reach the cloud endpoint with the supplied access token.

---

## Before You Start

You need:

- ✅ A Ruijie Cloud account with access to the target site
- ✅ A Ruijie-issued API AppID/Secret and access token
- ✅ The correct Ruijie Cloud regional hostname for your account

> ⚠️ Ruijie controls API access. Request credentials through the Ruijie Cloud API application process and **keep the token private**. Do not add it to screenshots, support tickets, source control, or chat messages.

---

## Add the Connection in WireSpot

1. Open **Routers** → **Add router**.
2. Choose **Ruijie / Reyee** as the brand.
3. Give the connection a recognizable site name.
4. Enter the **Ruijie Cloud hostname** and HTTPS port (`443` unless Ruijie gave you another value).
5. Enter the cloud account if useful for identification (optional).
6. Paste the **Ruijie Cloud access token** into the token field.
7. **Save** and use **Test connection**.

The access token is stored in WireSpot's secure storage. It is not included in normal router lists, reports, or backups.

---

## What the Test Does

WireSpot sends an HTTPS request to the configured cloud host:

```
/service/api/maint/devices?access_token=...
```

A successful response confirms:
- ✅ Cloud reachability
- ✅ Token acceptance

It does **not** change any router, Wi-Fi, portal, user, or voucher configuration.

---

## Current Limits

The current Ruijie connector supports **connection verification only**. These functions remain unavailable until their official API contracts are reviewed and tested:

- 🚫 Site and device views in the WireSpot dashboard
- 🚫 Captive portal configuration
- 🚫 Hotspot-user management
- 🚫 Voucher creation or deletion
- 🚫 Traffic and client-session management

For live hotspot management, continue using the Ruijie Cloud console or a supported MikroTik RouterOS connection.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **Authentication error** | Refresh or reissue the access token, then replace it in WireSpot |
| **Connection error** | Verify the exact regional Ruijie Cloud hostname and that the phone has internet |
| **Permission error** | Confirm the API application is approved for the relevant account/site |
| **Wrong host** | Never use a router LAN IP as the cloud host unless Ruijie explicitly provided a local-controller endpoint |
