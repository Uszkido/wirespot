import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/wireguard_settings.dart';

class WireGuardSettingsService {
  const WireGuardSettingsService(this._repository);

  static const _selectedTunnelKey = 'vpn.wireguard.selected_tunnel';
  static const _autoReconnectKey = 'vpn.wireguard.auto_reconnect';

  final SettingsRepository _repository;

  Future<WireGuardSettings> load() async {
    final selectedTunnelName = await _repository.readSetting(
      _selectedTunnelKey,
    );
    final autoReconnect = await _repository.readSetting(_autoReconnectKey);
    return WireGuardSettings(
      selectedTunnelName:
          selectedTunnelName == null || selectedTunnelName.trim().isEmpty
          ? 'wirespot'
          : selectedTunnelName.trim(),
      autoReconnectEnabled: autoReconnect == 'true',
    );
  }

  Future<void> save(WireGuardSettings settings) async {
    await _repository.writeSetting(
      _selectedTunnelKey,
      settings.selectedTunnelName.trim().isEmpty
          ? 'wirespot'
          : settings.selectedTunnelName.trim(),
    );
    await _repository.writeSetting(
      _autoReconnectKey,
      settings.autoReconnectEnabled ? 'true' : 'false',
    );
  }
}
