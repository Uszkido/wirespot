import 'dart:async';

import 'vpn_status.dart';
import 'wireguard_vpn_service.dart';

class WireGuardAutoReconnectService {
  WireGuardAutoReconnectService(this._vpnService);

  final WireGuardVpnService _vpnService;
  StreamSubscription<VpnStatus>? _subscription;
  String? _lastTunnelName;
  bool _isReconnectInFlight = false;

  void start({required String tunnelName}) {
    _lastTunnelName = tunnelName;
    _subscription ??= _vpnService.watchStatus().listen(_handleStatus);
  }

  Future<void> stop() async {
    _lastTunnelName = null;
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _handleStatus(VpnStatus status) async {
    if (_isReconnectInFlight || _lastTunnelName == null) {
      return;
    }
    if (status.state != VpnConnectionState.error) {
      return;
    }

    _isReconnectInFlight = true;
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      await _vpnService.connect(_lastTunnelName!);
    } finally {
      _isReconnectInFlight = false;
    }
  }
}
