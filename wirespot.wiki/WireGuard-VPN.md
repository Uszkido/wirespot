# 🔒 WireGuard VPN

## Why WireGuard?

WireSpot is designed around **WireGuard-first remote access** so operators do not need to expose RouterOS API ports directly to the internet. Instead, a private WireGuard tunnel secures all management traffic between the Android device and the router.

---

## Setup

### 1. Configure WireGuard on the Router

On your MikroTik router, set up a WireGuard interface and peer for the Android device. Ensure the peer has an allowed IP and the router's WireGuard interface is listening.

```routeros
/interface wireguard add name=wg0 listen-port=13231
/interface wireguard peers add interface=wg0 public-key="<ANDROID_PUBLIC_KEY>" allowed-address=10.0.0.2/32
```

### 2. Import Config into WireSpot

WireSpot supports two import methods:

| Method | How |
|--------|-----|
| **File import** | Import a `.conf` file with `[Interface]` and `[Peer]` sections |
| **QR scan** | Scan a WireGuard QR code using the built-in camera scanner |

1. Open **Settings** → **WireGuard VPN**.
2. Choose **Import config** or **Scan QR**.
3. Review the parsed tunnel configuration.

### 3. Connect

1. Tap **Connect** on the WireGuard tunnel card.
2. If this is the first time, Android will ask for **VPN permission** — approve it.
3. If the permission dialog doesn't appear, go to **Settings** → **Permission readiness** → **Request VPN consent**.
4. After permission is granted, connect again if needed.

---

## Features

| Feature | Description |
|---------|-------------|
| **Config parsing** | Full `.conf` file and QR code parsing |
| **Tunnel status** | Real-time connected/disconnected status |
| **Connect / disconnect** | Through Android platform channel to official WireGuard backend |
| **Tunnel logs** | View tunnel activity and diagnostic messages |
| **Statistics** | Transfer statistics (bytes sent/received) |
| **Auto-reconnect** | Coordinator for automatic tunnel recovery |
| **VPN guard** | Blocks RouterOS API commands when VPN is required but disconnected |

---

## VPN Guard

When a router is configured with a private tunnel mode (WireGuard, Back To Home, or ZeroTier), WireSpot enforces a **VPN guard** before any RouterOS API communication:

- ✅ VPN connected → API commands proceed
- ❌ VPN disconnected → API commands are blocked with a clear message

This prevents accidental unencrypted API traffic over the public internet.

---

## Android Backend

WireSpot uses the **official WireGuard Android tunnel library** (`com.wireguard.android:tunnel`) and registers the WireGuard `GoBackend` VPN service in the Android manifest.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| VPN won't connect | Re-import config, check `[Interface]` and `[Peer]` syntax |
| Permission not appearing | Use Settings → Permission readiness → Request VPN consent |
| Tunnel times out | Verify router WireGuard peer config, allowed IPs, and port |
| Router unreachable over VPN | Check the VPN address matches the router record host/ip |
| Auto-reconnect fails | Toggle auto-reconnect off and on, verify phone network |

### RouterOS Peer Verification

Confirm the Android peer has an allowed IP and shows a recent handshake:

```routeros
/interface wireguard peers print detail
```
