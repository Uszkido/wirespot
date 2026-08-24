enum RouterCapability {
  connectionTest(label: 'Connection test'),
  dashboardSnapshot(label: 'Dashboard snapshot'),
  hotspotUsers(label: 'Hotspot users'),
  hotspotSetupPresets(label: 'Hotspot setup presets'),
  voucherProvisioning(label: 'Voucher provisioning'),
  trafficMonitoring(label: 'Traffic monitoring'),
  cloudController(label: 'Cloud/controller API');

  const RouterCapability({required this.label});

  final String label;
}

enum RouterVendor {
  mikrotik(
    label: 'MikroTik RouterOS',
    description: 'Full RouterOS API support for hotspot users and vouchers.',
    defaultPort: 8728,
    defaultUseSsl: false,
    usesRouterOsApi: true,
    managementSurfaceLabel: 'RouterOS API',
    requiresController: false,
    securityNote:
        'Prefer private VPN or LAN access with a least-privilege account.',
    setupChecklist: [
      'Enable the RouterOS API service on a trusted port.',
      'Use WireGuard, Back To Home, ZeroTier, or a trusted LAN for access.',
      'Create a least-privilege RouterOS user for WireSpot operations.',
    ],
    activeCapabilities: {
      RouterCapability.connectionTest,
      RouterCapability.dashboardSnapshot,
      RouterCapability.hotspotUsers,
      RouterCapability.hotspotSetupPresets,
      RouterCapability.voucherProvisioning,
      RouterCapability.trafficMonitoring,
    },
  ),
  ruijie(
    label: 'Ruijie / Reyee',
    description: 'Ruijie Cloud connection verification is available.',
    defaultPort: 443,
    defaultUseSsl: true,
    usesRouterOsApi: false,
    managementSurfaceLabel: 'Ruijie Cloud or local controller',
    requiresController: true,
    securityNote:
        'Use HTTPS controller access and keep site credentials separate.',
    setupChecklist: [
      'Prepare Ruijie Cloud or controller access for the managed site.',
      'Keep gateway, access point, and captive portal details ready.',
      'Use HTTPS controller/cloud credentials when the connector ships.',
    ],
    activeCapabilities: {
      RouterCapability.connectionTest,
      RouterCapability.cloudController,
    },
    plannedCapabilities: {
      RouterCapability.dashboardSnapshot,
      RouterCapability.hotspotUsers,
      RouterCapability.hotspotSetupPresets,
      RouterCapability.voucherProvisioning,
      RouterCapability.trafficMonitoring,
      RouterCapability.cloudController,
    },
  ),
  openWrt(
    label: 'OpenWrt',
    description: 'OpenWrt SSH/LuCI integration planned.',
    defaultPort: 22,
    defaultUseSsl: false,
    usesRouterOsApi: false,
    managementSurfaceLabel: 'SSH or LuCI',
    requiresController: false,
    securityNote:
        'Do not expose SSH or LuCI publicly; prefer VPN or trusted LAN access.',
    setupChecklist: [
      'Enable trusted SSH or LuCI access from the WireSpot device/network.',
      'Prepare captive portal package details such as NoDogSplash or CoovaChilli.',
      'Use a limited operator account where possible.',
    ],
    plannedCapabilities: {
      RouterCapability.connectionTest,
      RouterCapability.dashboardSnapshot,
      RouterCapability.hotspotSetupPresets,
      RouterCapability.trafficMonitoring,
    },
  ),
  tpLinkOmada(
    label: 'TP-Link Omada',
    description: 'Omada Controller integration planned.',
    defaultPort: 443,
    defaultUseSsl: true,
    usesRouterOsApi: false,
    managementSurfaceLabel: 'Omada Controller',
    requiresController: true,
    securityNote: 'Use HTTPS controller access with a scoped operator account.',
    setupChecklist: [
      'Prepare Omada Controller access for the target site.',
      'Keep portal, WLAN, voucher, and client policies ready.',
      'Use HTTPS controller credentials when the connector ships.',
    ],
    plannedCapabilities: {
      RouterCapability.connectionTest,
      RouterCapability.dashboardSnapshot,
      RouterCapability.hotspotUsers,
      RouterCapability.hotspotSetupPresets,
      RouterCapability.voucherProvisioning,
      RouterCapability.trafficMonitoring,
      RouterCapability.cloudController,
    },
  ),
  ubiquitiUniFi(
    label: 'Ubiquiti UniFi',
    description: 'UniFi Controller integration planned.',
    defaultPort: 443,
    defaultUseSsl: true,
    usesRouterOsApi: false,
    managementSurfaceLabel: 'UniFi Network controller',
    requiresController: true,
    securityNote: 'Use HTTPS controller access with a scoped operator account.',
    setupChecklist: [
      'Prepare UniFi Network controller access for the target site.',
      'Keep guest hotspot, WLAN, and voucher policies ready.',
      'Use HTTPS controller credentials when the connector ships.',
    ],
    plannedCapabilities: {
      RouterCapability.connectionTest,
      RouterCapability.dashboardSnapshot,
      RouterCapability.hotspotUsers,
      RouterCapability.hotspotSetupPresets,
      RouterCapability.voucherProvisioning,
      RouterCapability.trafficMonitoring,
      RouterCapability.cloudController,
    },
  ),
  generic(
    label: 'Generic router',
    description: 'Generic SSH/SNMP monitoring integration planned.',
    defaultPort: 443,
    defaultUseSsl: true,
    usesRouterOsApi: false,
    managementSurfaceLabel: 'SSH, SNMP, or HTTPS API',
    requiresController: false,
    securityNote:
        'Prefer read-only monitoring credentials until a connector is verified.',
    setupChecklist: [
      'Confirm the router exposes SSH, SNMP, or an HTTPS management API.',
      'Use a private management network or VPN where possible.',
      'Treat automation as monitoring-first until a brand connector exists.',
    ],
    plannedCapabilities: {
      RouterCapability.connectionTest,
      RouterCapability.dashboardSnapshot,
      RouterCapability.trafficMonitoring,
    },
  );

  const RouterVendor({
    required this.label,
    required this.description,
    required this.defaultPort,
    required this.defaultUseSsl,
    required this.usesRouterOsApi,
    required this.managementSurfaceLabel,
    required this.requiresController,
    required this.securityNote,
    required this.setupChecklist,
    this.activeCapabilities = const {},
    this.plannedCapabilities = const {},
  });

  final String label;
  final String description;
  final int defaultPort;
  final bool defaultUseSsl;
  final bool usesRouterOsApi;
  final String managementSurfaceLabel;
  final bool requiresController;
  final String securityNote;
  final List<String> setupChecklist;
  final Set<RouterCapability> activeCapabilities;
  final Set<RouterCapability> plannedCapabilities;

  bool get hasLiveConnector => activeCapabilities.isNotEmpty;

  bool get supportsHotspotVouchers =>
      supports(RouterCapability.voucherProvisioning);

  bool get usesCloudAccessToken => this == RouterVendor.ruijie;

  bool supports(RouterCapability capability) {
    return activeCapabilities.contains(capability);
  }

  bool plans(RouterCapability capability) {
    return !supports(capability) && plannedCapabilities.contains(capability);
  }

  String get activeCapabilitySummary {
    if (activeCapabilities.isEmpty) {
      return 'No live connector yet';
    }
    return activeCapabilities.map((capability) => capability.label).join(', ');
  }

  String get plannedCapabilitySummary {
    if (plannedCapabilities.isEmpty) {
      return 'No additional capabilities planned yet';
    }
    return plannedCapabilities.map((capability) => capability.label).join(', ');
  }

  static RouterVendor fromName(String? name) {
    return RouterVendor.values.firstWhere(
      (value) => value.name == name,
      orElse: () => RouterVendor.mikrotik,
    );
  }
}

enum RouterRemoteAccessMode {
  localLan(
    label: 'Local LAN',
    description: 'Direct on-site access from the same trusted network.',
    requiresPrivateTunnel: false,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  wireGuard(
    label: 'WireGuard',
    description: 'Private VPN access using a WireGuard tunnel.',
    requiresPrivateTunnel: true,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  backToHome(
    label: 'MikroTik Back To Home',
    description: 'MikroTik assisted WireGuard access for routers behind NAT.',
    requiresPrivateTunnel: true,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  zeroTier(
    label: 'ZeroTier',
    description: 'Private overlay network access through ZeroTier.',
    requiresPrivateTunnel: true,
    recommendedPort: 8728,
    recommendedSsl: false,
  ),
  publicApiSsl(
    label: 'Public API-SSL',
    description:
        'Advanced public endpoint using RouterOS API-SSL and firewall limits.',
    requiresPrivateTunnel: false,
    recommendedPort: 8729,
    recommendedSsl: true,
  ),
  custom(
    label: 'Custom / Advanced',
    description: 'Operator-managed path with custom firewall and routing.',
    requiresPrivateTunnel: false,
    recommendedPort: 8728,
    recommendedSsl: false,
  );

  const RouterRemoteAccessMode({
    required this.label,
    required this.description,
    required this.requiresPrivateTunnel,
    required this.recommendedPort,
    required this.recommendedSsl,
  });

  final String label;
  final String description;
  final bool requiresPrivateTunnel;
  final int recommendedPort;
  final bool recommendedSsl;

  static RouterRemoteAccessMode fromName(String? name, {bool? requireVpn}) {
    final mode = RouterRemoteAccessMode.values.firstWhere(
      (value) => value.name == name,
      orElse: () => requireVpn == false
          ? RouterRemoteAccessMode.localLan
          : RouterRemoteAccessMode.wireGuard,
    );
    return mode;
  }
}

class RouterEntity {
  const RouterEntity({
    required this.id,
    required this.name,
    required this.host,
    required this.username,
    this.vendor = RouterVendor.mikrotik,
    this.groupId,
    this.apiPort = 8728,
    this.useSsl = false,
    this.requireVpn = true,
    this.remoteAccessMode = RouterRemoteAccessMode.wireGuard,
    this.identity,
    this.version,
    this.boardName,
    this.isEnabled = true,
    this.lastConnectedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? groupId;
  final RouterVendor vendor;
  final String name;
  final String host;
  final int apiPort;
  final bool useSsl;
  final bool requireVpn;
  final RouterRemoteAccessMode remoteAccessMode;
  final String username;
  final String? identity;
  final String? version;
  final String? boardName;
  final bool isEnabled;
  final DateTime? lastConnectedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get requiresPrivateTunnel =>
      requireVpn || remoteAccessMode.requiresPrivateTunnel;

  bool get supportsHotspotVouchers => vendor.supportsHotspotVouchers;

  Map<String, Object?> toJson() => {
        'id': id,
        'groupId': groupId,
        'vendor': vendor.name,
        'name': name,
        'host': host,
        'apiPort': apiPort,
        'useSsl': useSsl,
        'requireVpn': requireVpn,
        'remoteAccessMode': remoteAccessMode.name,
        'username': username,
        'identity': identity,
        'version': version,
        'boardName': boardName,
        'isEnabled': isEnabled,
        'lastConnectedAt': lastConnectedAt?.toUtc().toIso8601String(),
        'createdAt': createdAt?.toUtc().toIso8601String(),
        'updatedAt': updatedAt?.toUtc().toIso8601String(),
      };
}
