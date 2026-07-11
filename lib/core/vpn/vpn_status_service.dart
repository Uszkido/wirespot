import 'vpn_status.dart';
import 'wireguard_vpn_service.dart';

class VpnStatusService {
  const VpnStatusService(this._vpnService);

  final WireGuardVpnService _vpnService;

  Future<VpnStatus> currentStatus() => _vpnService.currentStatus();
}
