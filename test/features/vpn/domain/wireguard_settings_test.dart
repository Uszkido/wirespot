import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/vpn/domain/entities/wireguard_settings.dart';

void main() {
  test('WireGuardSettings copyWith preserves unspecified values', () {
    const settings = WireGuardSettings(
      selectedTunnelName: 'remote-office',
      autoReconnectEnabled: true,
    );

    final updated = settings.copyWith(selectedTunnelName: 'site-branch');

    expect(updated.selectedTunnelName, 'site-branch');
    expect(updated.autoReconnectEnabled, isTrue);
  });
}
