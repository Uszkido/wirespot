import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../storage/secure_storage_keys.dart';
import '../storage/secure_storage_service.dart';
import 'vpn_statistics.dart';
import 'vpn_status.dart';
import 'wireguard_config.dart';
import 'wireguard_tunnel.dart';
import 'wireguard_vpn_service.dart';

/// WireGuard integration for Windows installations with the official
/// WireGuard client installed. The official CLI installs tunnel services, so
/// the tunnel remains managed by Windows rather than by a Flutter process.
class WindowsWireGuardVpnService implements WireGuardVpnService {
  WindowsWireGuardVpnService({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;
  final _statusController = StreamController<VpnStatus>.broadcast();
  String? _activeTunnel;

  @override
  Future<void> importConfig(WireGuardConfig config) async {
    await _secureStorage.write(
      SecureStorageKeys.wireGuardConfig(config.name),
      config.rawConfig,
    );
    final directory = await _configDirectory();
    await File(
      '${directory.path}/${_safeName(config.name)}.conf',
    ).writeAsString(config.rawConfig);
  }

  @override
  Future<void> importConfigFromQrText({
    required String name,
    required String qrText,
  }) => importConfig(WireGuardConfig.parse(name: name, config: qrText));

  @override
  Future<void> connect(String tunnelName) async {
    final config = await _secureStorage.read(
      SecureStorageKeys.wireGuardConfig(tunnelName),
    );
    if (config == null) {
      throw StateError('No WireGuard configuration is saved for $tunnelName.');
    }
    final directory = await _configDirectory();
    final configFile = File('${directory.path}/${_safeName(tunnelName)}.conf');
    if (!await configFile.exists()) {
      await configFile.writeAsString(config);
    }
    await _runWireGuard(['/installtunnelservice', configFile.path]);
    _activeTunnel = tunnelName;
    _statusController.add(
      VpnStatus(state: VpnConnectionState.connected, tunnelName: tunnelName),
    );
  }

  @override
  Future<void> requestPermission() async {
    // Windows tunnel services request elevation through the WireGuard client.
  }

  @override
  Future<void> disconnect() async {
    final tunnel = _activeTunnel;
    if (tunnel == null) return;
    await _runWireGuard(['/uninstalltunnelservice', _safeName(tunnel)]);
    _activeTunnel = null;
    _statusController.add(
      const VpnStatus(state: VpnConnectionState.disconnected),
    );
  }

  @override
  Future<VpnStatus> currentStatus() async => _activeTunnel == null
      ? const VpnStatus(state: VpnConnectionState.disconnected)
      : VpnStatus(
          state: VpnConnectionState.connected,
          tunnelName: _activeTunnel,
        );

  @override
  Future<VpnStatistics> statistics() async =>
      const VpnStatistics(rxBytes: 0, txBytes: 0);

  @override
  Future<List<String>> logs() async => const [
    'Windows WireGuard tunnels are managed by the WireGuard tunnel service.',
  ];

  @override
  Future<List<WireGuardTunnel>> getSavedTunnels() async {
    final values = await _secureStorage.readAll();
    return values.entries
        .where((entry) => entry.key.startsWith('wireguard_config_'))
        .map(
          (entry) => WireGuardTunnel(
            name: entry.key.replaceFirst('wireguard_config_', ''),
            config: entry.value,
          ),
        )
        .toList();
  }

  @override
  Future<void> importConfigString(String rawConfig) async {
    await importConfig(
      WireGuardConfig.parse(name: 'Imported Tunnel', config: rawConfig),
    );
  }

  @override
  Stream<VpnStatus> watchStatus() => _statusController.stream;

  Future<Directory> _configDirectory() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory(
      '${root.path}${Platform.pathSeparator}wireguard',
    );
    await directory.create(recursive: true);
    return directory;
  }

  Future<void> _runWireGuard(List<String> arguments) async {
    ProcessResult? result;
    for (final executable in [
      'wireguard.exe',
      r'C:\Program Files\WireGuard\wireguard.exe',
    ]) {
      try {
        result = await Process.run(executable, arguments);
        break;
      } on ProcessException {
        continue;
      }
    }
    if (result == null) {
      throw StateError(
        'WireGuard for Windows is not installed. Install it from wireguard.com.',
      );
    }
    if (result.exitCode != 0) {
      throw StateError(
        'WireGuard could not update the tunnel: ${result.stderr}'.trim(),
      );
    }
  }

  String _safeName(String name) =>
      name.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
}
