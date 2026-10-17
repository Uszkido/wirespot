# WireSpot FreeRADIUS service

This bundle provides the RADIUS server used by RouterOS PPPoE subscriber access.
WireSpot configures the MikroTik PPPoE server and points it at this service;
FreeRADIUS performs the username/password check, plan speed limit, and session
accounting.

## Start it

```bash
cd radius
cp .env.example .env
# Edit .env and set a long random RADIUS_CLIENT_SECRET and the router IP/CIDR.
docker compose up -d --build
docker compose ps
```

The server listens on UDP `1812` (authentication) and UDP `1813` (accounting).
Allow those ports only from the router's management/LAN address. Do not expose
RADIUS directly to the public Internet.

## RouterOS values

Use these values in WireSpot's **PPPoE subscriber access** setup:

- RADIUS address: the private IP or DNS name of this FreeRADIUS host
- Authentication port: `1812`
- Accounting port: `1813`
- Shared secret: the `RADIUS_CLIENT_SECRET` value in `.env`
- PPPoE service: `ppp`

The app provisions `/radius`, `/ppp/aaa`, `/ppp/profile`, and the PPPoE server.
The router and RADIUS host must be able to reach each other over the LAN or a
private network; PPPoE itself is not a remote-management tunnel.

## Add a subscriber or voucher

For the file-backed starter configuration, edit `config/authorize` and add an
entry such as:

```text
customer-001  Cleartext-Password := "use-a-random-password"
    Mikrotik-Rate-Limit := "5M/5M",
    Session-Timeout := 3600
```

Then reload the service:

```bash
docker compose restart freeradius
```

For production, replace the file module with SQL or REST-backed provisioning
so WireSpot can create, expire, suspend, and account for subscribers without
editing a container file. Never commit real subscriber passwords or shared
secrets.
