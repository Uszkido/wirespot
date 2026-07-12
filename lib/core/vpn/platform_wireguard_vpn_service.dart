import 'dart:async';

import 'package:flutter/services.dart';

import '../storage/secure_storage_keys.dart';
import '../storage/secure_storage_service.dart';
import 'vpn_statistics.dart';
import 'vpn_status.dart';
import 'wireguard_config.dart';
import 'wireguard_tunnel.dart';
import 'wireguard_vpn_service.dart';

class PlatformWireGuardVpnService implements WireGuardVpnService {
  PlatformWireGuardVpnService({
    required SecureStorageService secureStorage,
    MethodChannel? methodChannel,
    EventChannel? statusChannel,
  }) : _secureStorage = secureStorage,
       _methodChannel = methodChannel ?? const MethodChannel(_methodName),
       _statusChannel = statusChannel ?? const EventChannel(_statusName);

  static const _methodName = 'com.wirespot.app/wireguard';
  static const _statusName = 'com.wirespot.app/wireguard_status';

  final SecureStorageService _secureStorage;
  final MethodChannel _methodChannel;
  final EventChannel _statusChannel;

  @override
  Future<void> importConfig(WireGuardConfig config) async {
    await _secureStorage.write(
      SecureStorageKeys.wireGuardConfig(config.name),
      config.rawConfig,
    );
    final tunnel = WireGuardTunnel(name: config.name, config: config.rawConfig);
    await _methodChannel.invokeMethod<void>(
      'importConfig',
      tunnel.toPlatformMap(),
    );
  }

  @override
  Future<void> importConfigFromQrText({
    required String name,
    required String qrText,
  }) {
    return importConfig(WireGuardConfig.parse(name: name, config: qrText));
  }

  @override
  Future<void> connect(String tunnelName) async {
    final config = await _secureStorage.read(
      SecureStorageKeys.wireGuardConfig(tunnelName),
    );
    if (config != null) {
      await _methodChannel.invokeMethod<void>(
        'importConfig',
        WireGuardTunnel(name: tunnelName, config: config).toPlatformMap(),
      );
    }
    return _methodChannel.invokeMethod<void>('connect', {'name': tunnelName});
  }

  @override
  Future<void> disconnect() {
    return _methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<VpnStatus> currentStatus() async {
    final result = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'status',
    );
    return VpnStatus.fromJson(result ?? const {});
  }

  @override
  Future<VpnStatistics> statistics() async {
    final result = await _methodChannel.invokeMapMethod<Object?, Object?>(
      'statistics',
    );
    return VpnStatistics.fromJson(result ?? const {});
  }

  @override
  Future<List<String>> logs() async {
    final result = await _methodChannel.invokeListMethod<String>('logs');
    return result ?? const [];
  }

  @override
  Stream<VpnStatus> watchStatus() {
    return _statusChannel.receiveBroadcastStream().map((event) {
      if (event is Map<Object?, Object?>) {
        return VpnStatus.fromJson(event);
      }
      return const VpnStatus(
        state: VpnConnectionState.error,
        message: 'Invalid VPN status event received from Android.',
      );
    });
  }
}
