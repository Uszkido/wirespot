# Ruijie Cloud Setup

WireSpot can verify a Ruijie/Reyee cloud connection using Ruijie Cloud's
device-list API. This is an early, read-only integration: it confirms that
WireSpot can reach the cloud endpoint with the supplied access token.

## Before You Start

You need:

- a Ruijie Cloud account with access to the target site;
- a Ruijie-issued API AppID/Secret and access token; and
- the correct Ruijie Cloud regional hostname supplied for your account.

Ruijie controls API access. Request credentials through the Ruijie Cloud API
application process and keep the token private. Do not add it to screenshots,
support tickets, source control, or chat messages.

## Add The Connection In WireSpot

1. Open **Routers** and select **Add router**.
2. Choose **Ruijie / Reyee** as the brand.
3. Give the connection a recognizable site name.
4. Enter the Ruijie Cloud hostname and HTTPS port (`443` unless Ruijie gave
   you another value).
5. Enter the cloud account if useful for identification. It is optional for
   this connection check.
6. Paste the Ruijie Cloud access token into **Ruijie Cloud access token**.
7. Save and use **Test connection**.

The access token is stored in WireSpot's secure storage. It is not included in
normal router lists, reports, or backups.

## What The Test Does

WireSpot sends an HTTPS request to the configured cloud host at:

```text
/service/api/maint/devices?access_token=...
```

A successful response confirms cloud reachability and token acceptance. It does
not change any router, Wi-Fi, portal, user, or voucher configuration.

## Current Limits

The current Ruijie connector supports connection verification only. The
following functions remain unavailable until their official API contracts are
reviewed and tested:

- site and device views in the WireSpot dashboard;
- captive portal configuration;
- hotspot-user management;
- voucher creation or deletion; and
- traffic and client-session management.

For live hotspot management, continue using the Ruijie Cloud console or a
supported MikroTik RouterOS connection in WireSpot.

## Troubleshooting

- **Authentication error:** refresh or reissue the access token, then replace
  it in WireSpot.
- **Connection error:** verify the exact regional Ruijie Cloud hostname and
  that the phone has internet access.
- **Permission error:** confirm the API application is approved and has access
  to the relevant Ruijie Cloud account/site.
- **Never use a router LAN IP as the cloud host** unless Ruijie explicitly
  provided a compatible local-controller API endpoint.
