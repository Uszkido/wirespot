# 🔌 Router Setup and Fleet Management

## Adding a Router

### Step-by-Step

1. Open **Dashboard** → **Routers** → **Add router**.
2. **Choose the router brand:**
   - MikroTik *(full live connector)*
   - Ruijie / Reyee *(cloud connection test)*
   - OpenWrt *(planned connector)*
   - TP-Link Omada *(planned connector)*
   - Ubiquiti UniFi *(planned connector)*
   - Generic *(planned connector)*
3. Enter **router name**, **host/IP**, **port**, **username**, and **password**.
   - For Ruijie/Reyee: enter Ruijie Cloud host and access token instead.
4. Choose **SSL** if the router's API or controller service supports it.
5. Choose the **connection mode** (see below).
6. Optionally assign a **Router group / site**.
7. **Save** and tap **Test Connection**.

> **Note:** RouterOS API access must be enabled on the MikroTik router. Default API port is `8728`; API-SSL is `8729` when configured.

---

## Connection / Remote Access Modes

| Mode | Description | VPN Guard |
|------|-------------|-----------|
| **Local LAN** | Direct on-site access from the same network | No |
| **WireGuard** | Private VPN tunnel access | Yes |
| **MikroTik Back To Home** | MikroTik-assisted WireGuard for routers behind NAT | Yes |
| **ZeroTier** | Private overlay network access | Yes |
| **Public API-SSL** | Advanced public endpoint with RouterOS API-SSL + firewall limits | No |
| **Custom / Advanced** | Operator-managed routing and firewall path | Depends |

### Local LAN Mode

Use when the phone is on the same network as the router:

```
Router IP: 192.168.88.1
API port:  8728
Require WireGuard: Off
```

> ⚠️ Do not use local mode for public internet access — it's for same-site management only.

### WireGuard Remote Mode

1. Open **Settings** → **WireGuard VPN**.
2. Import a WireGuard config or scan a QR code.
3. Approve Android VPN permission if prompted.
4. Tap **Connect**.
5. Return to **Routers** and test the connection.

See [[WireGuard VPN]] for detailed VPN setup.

---

## Multi-Router Fleet Operations

### Active Router

WireSpot can keep many router records and work with them as a fleet. The router with the ✓ check mark is the **active router** used by default in Dashboard, Hotspot, and Vouchers.

- Select **Use this router** from any router menu to switch.
- Use the Dashboard switch icon to change quickly.
- The choice is remembered across app restarts.

### Test All Connections

Use **Test all router connections** to test available routers concurrently. The result identifies every online and unavailable router without one router blocking the others.

### Router Groups

Organize routers by business, branch, hotel, estate, or site:

1. When adding/editing a router, choose **Router group / site**.
2. Create a new group from the same form.
3. Use the **Fleet group** filter on the Routers screen to focus the list.
4. Run connection checks only for the selected group.

> The active router is only the router currently in focus — it does not stop WireSpot from testing or scheduling work across other routers.

---

## Troubleshooting Connection Issues

| Problem | Check |
|---------|-------|
| Cannot connect | Confirm phone network/VPN route, host/IP, port |
| Login fails | Wrong username/password or disabled API service |
| SSL fails | API-SSL not configured correctly on RouterOS |
| VPN router fails | WireGuard must be connected before testing |
| Local LAN fails | Phone must be on the same network as the router |

See [[Troubleshooting]] for full diagnostics.
