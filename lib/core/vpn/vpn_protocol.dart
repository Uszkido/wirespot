enum VpnProtocol {
  wireGuard,
  openVpn,
  ipsecIkev2,
  sstp;

  String get displayName => switch (this) {
    VpnProtocol.wireGuard => 'WireGuard (UDP)',
    VpnProtocol.openVpn => 'OpenVPN (TLS/UDP/TCP)',
    VpnProtocol.ipsecIkev2 => 'IPsec / IKEv2 (Enterprise)',
    VpnProtocol.sstp => 'SSTP / OpenConnect (SSL)',
  };

  String get badgeLabel => switch (this) {
    VpnProtocol.wireGuard => 'WG',
    VpnProtocol.openVpn => 'OVPN',
    VpnProtocol.ipsecIkev2 => 'IPSEC',
    VpnProtocol.sstp => 'SSTP',
  };

  static VpnProtocol parse(String? value) {
    return switch (value?.toLowerCase()) {
      'openvpn' || 'ovpn' => VpnProtocol.openVpn,
      'ipsec' ||
      'ikev2' ||
      'ipsec_ikev2' ||
      'ipsecikev2' => VpnProtocol.ipsecIkev2,
      'sstp' || 'openconnect' => VpnProtocol.sstp,
      _ => VpnProtocol.wireGuard,
    };
  }
}
