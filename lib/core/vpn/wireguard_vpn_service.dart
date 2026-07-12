import 'vpn_statistics.dart';
import 'vpn_status.dart';
import 'wireguard_config.dart';

abstract interface class WireGuardVpnService {
  Future<void> importConfig(WireGuardConfig config);

  Future<void> importConfigFromQrText({
    required String name,
    required String qrText,
  });

  Future<void> connect(String tunnelName);

  Future<void> requestPermission();

  Future<void> disconnect();

  Future<VpnStatus> currentStatus();

  Future<VpnStatistics> statistics();

  Future<List<String>> logs();

  Stream<VpnStatus> watchStatus();
}
