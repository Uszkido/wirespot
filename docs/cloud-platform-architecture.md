# WireSpot Cloud Platform Architecture

## Product boundary

WireSpot remains one product with two coordinated operating modes:

- The Flutter app is the operator application. It retains local RouterOS and
  WireGuard workflows for on-site work and safe degraded operation.
- WireSpot Cloud is the shared source of truth for organizations, locations,
  staff, customers, plans, vouchers, payments, RADIUS policy, accounting, and
  fleet reporting.

Local records are never silently discarded. Changes made while cloud access is
unavailable are recorded as sync operations and reconciled once connectivity is
restored. Conflicts are visible to operators; cloud payment and RADIUS state is
never overwritten by a client without server authorization.

## Existing WireSpot dependency map

| Existing component | Current responsibility | Cloud extension |
| --- | --- | --- |
| `RouterEntity` / `RouterRepository` | Local router records, groups, credentials | Add cloud router identity, organization and location mapping through the API while keeping encrypted local credentials. |
| `RouterConnectionService` | RouterOS and multi-vendor command routing | Keep as the device-management transport. Backend workers use the same RouterOS semantics for synchronization. |
| `RouterOsHotspotService` | Hotspot users, profiles, sessions, queues, setup | Continue local operations; cloud sync schedules durable, retried router configuration jobs. |
| `VoucherGenerationService` / `VoucherRepository` | Voucher creation and local history | Map existing vouchers to the single cloud plan/voucher model; do not introduce a second voucher engine. |
| `ReportRepository` / `ReportExportService` | Local sales summaries and file export | Cloud API supplies tenant-scoped consolidated sales, payments, usage, and accounting reports. |
| `WireGuardVpnService` | Secure remote tunnel management | One preferred secure route for RouterOS management, not a required route. |
| `AuthService` | Local device PIN session | Remains app-lock protection. Laravel Sanctum supplies cloud identity, organization membership, and server authorization. |
| Drift/SQLite + secure storage | Offline cache and encrypted sensitive local values | PostgreSQL becomes shared source of truth; local Drift stays an offline cache and operation queue. |

## Management, authentication, and transport

```text
Flutter app / Laravel workers
        |
        +-- RouterOS API: configure and manage routers
        |     - hotspot profiles, queues, users when required
        |     - active sessions, disconnects, health, configuration sync
        |
        +-- FreeRADIUS: central customer authentication, authorization,
        |   and accounting
        |     - plan bandwidth, data, time, device/session policy
        |     - accounting starts/interims/stops
        |
        +-- Connectivity strategy (per router)
              1. trusted LAN
              2. WireGuard
              3. approved overlay network such as Tailscale/ZeroTier
              4. MikroTik Back to Home where supported
              5. explicitly approved RouterOS API over TLS + allowlist
```

RouterOS API is for management and synchronization. FreeRADIUS is for central
authentication, authorization, and accounting. Neither replaces the other.

## Cloud services

The deployable cloud stack is:

```text
Nginx
  +-- Laravel API and queue workers
  +-- Next.js captive portal
  +-- PostgreSQL (source of truth)
  +-- Redis (queues, cache, rate limits)
  +-- FreeRADIUS (auth/accounting against PostgreSQL)
```

Laravel owns tenant-scoped REST APIs, Sanctum authentication, authorization
policies, payment webhook verification, audit logs, and background jobs.
FreeRADIUS reads centrally generated policy records and writes accounting data.
The captive portal only receives customer/portal endpoints; it never receives
operator administration access.

## Synchronization rules

1. Every tenant-owned cloud record contains `organization_id` and is queried
   through tenant-scoped policies.
2. Each app mutation carries a UUID idempotency key. Replaying an offline
   operation cannot create duplicate vouchers or payments.
3. Router sync jobs are queued in Laravel/Redis with retry, backoff, status,
   and audit records. Offline routers are retried rather than marked healthy.
4. Payment confirmation is webhook-driven and idempotent. Redirect pages never
   activate service by themselves.
5. Router credentials, RADIUS shared secrets, payment secrets, and Sanctum
   tokens are encrypted and excluded from logs and source control.
6. A cloud failure does not grant access by default. Existing authenticated
   sessions follow RouterOS/RADIUS timeout policy.

## Delivery order

1. Install Docker Desktop with WSL 2, PHP/Composer, and Node.js on the
   workstation.
2. Scaffold Laravel API, PostgreSQL, Redis, FreeRADIUS, and portal containers.
3. Implement organizations, roles, locations, and tenant-safe router API.
4. Add Flutter cloud sign-in, API configuration, local sync queue, and router
   mapping without removing local RouterOS workflows.
5. Migrate unified plans, customers, and existing vouchers to cloud-backed
   models.
6. Add RADIUS policy/accounting, captive portal, and verified payment flows.

## Workstation prerequisites

This repository currently has Flutter tooling only. Before running the cloud
stack locally, install:

- Docker Desktop with WSL 2 integration
- PHP 8.3+ and Composer 2
- Node.js 22+ (for the Next.js portal)

No production secrets belong in the repository. The cloud environment uses
local `.env` files created from committed `.env.example` templates.
