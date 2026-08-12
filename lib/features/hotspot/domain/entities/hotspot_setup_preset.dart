import 'hotspot_setup_input.dart';

enum HotspotSetupPreset {
  quickVoucher(
    label: 'Quick voucher hotspot',
    description: 'Small shop or cafe setup with a ready voucher network.',
  ),
  smallBusiness(
    label: 'Small business hotspot',
    description: 'Balanced setup for paid hotspot operators.',
  ),
  hotelGuest(
    label: 'Hotel guest Wi-Fi',
    description: 'Guest-friendly setup with HTTPS login enabled.',
  ),
  radiusManaged(
    label: 'RADIUS managed hotspot',
    description: 'External AAA setup for larger hotspot deployments.',
  );

  const HotspotSetupPreset({required this.label, required this.description});

  final String label;
  final String description;

  HotspotSetupInput toInput() {
    return switch (this) {
      HotspotSetupPreset.quickVoucher => const HotspotSetupInput(
        serverName: 'wirespot-hotspot',
        interfaceName: 'bridge',
        serverProfileName: 'wirespot-vouchers',
        hotspotAddress: '10.5.50.1',
        dnsName: 'hotspot.wirespot.local',
        addressPool: 'wirespot-pool',
        provisionNetwork: true,
        ipAddressWithPrefix: '10.5.50.1/24',
        poolName: 'wirespot-pool',
        poolRanges: '10.5.50.10-10.5.50.254',
        dhcpServerName: 'wirespot-dhcp',
        dhcpNetwork: '10.5.50.0/24',
        dhcpGateway: '10.5.50.1',
        dnsServers: '10.5.50.1,8.8.8.8',
        enableNatMasquerade: true,
        natSrcAddress: '10.5.50.0/24',
      ),
      HotspotSetupPreset.smallBusiness => const HotspotSetupInput(
        serverName: 'business-hotspot',
        interfaceName: 'bridge',
        serverProfileName: 'business-vouchers',
        hotspotAddress: '10.20.30.1',
        dnsName: 'login.business.local',
        addressPool: 'business-hotspot-pool',
        provisionNetwork: true,
        ipAddressWithPrefix: '10.20.30.1/24',
        poolName: 'business-hotspot-pool',
        poolRanges: '10.20.30.20-10.20.30.250',
        dhcpServerName: 'business-hotspot-dhcp',
        dhcpNetwork: '10.20.30.0/24',
        dhcpGateway: '10.20.30.1',
        dnsServers: '10.20.30.1,1.1.1.1',
        enableNatMasquerade: true,
        natSrcAddress: '10.20.30.0/24',
      ),
      HotspotSetupPreset.hotelGuest => const HotspotSetupInput(
        serverName: 'guest-hotspot',
        interfaceName: 'bridge',
        serverProfileName: 'hotel-guests',
        hotspotAddress: '10.30.40.1',
        dnsName: 'guest.login',
        addressPool: 'hotel-guest-pool',
        provisionNetwork: true,
        ipAddressWithPrefix: '10.30.40.1/24',
        poolName: 'hotel-guest-pool',
        poolRanges: '10.30.40.20-10.30.40.250',
        dhcpServerName: 'hotel-guest-dhcp',
        dhcpNetwork: '10.30.40.0/24',
        dhcpGateway: '10.30.40.1',
        dnsServers: '10.30.40.1,8.8.8.8',
        enableNatMasquerade: true,
        natSrcAddress: '10.30.40.0/24',
        loginByHttps: true,
      ),
      HotspotSetupPreset.radiusManaged => const HotspotSetupInput(
        serverName: 'radius-hotspot',
        interfaceName: 'bridge',
        serverProfileName: 'radius-managed',
        hotspotAddress: '10.40.50.1',
        dnsName: 'radius.login',
        addressPool: 'radius-hotspot-pool',
        provisionNetwork: true,
        ipAddressWithPrefix: '10.40.50.1/24',
        poolName: 'radius-hotspot-pool',
        poolRanges: '10.40.50.20-10.40.50.250',
        dhcpServerName: 'radius-hotspot-dhcp',
        dhcpNetwork: '10.40.50.0/24',
        dhcpGateway: '10.40.50.1',
        dnsServers: '10.40.50.1,1.1.1.1',
        enableNatMasquerade: true,
        natSrcAddress: '10.40.50.0/24',
        useRadius: true,
      ),
    };
  }
}
