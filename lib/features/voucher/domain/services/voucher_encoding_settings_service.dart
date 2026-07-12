import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/voucher_encoding_settings.dart';

class VoucherEncodingSettingsService {
  const VoucherEncodingSettingsService(this._settingsRepository);

  static const _keys = [
    'voucher.encoding.mode',
    'voucher.encoding.characterSet',
    'voucher.encoding.defaultPrefix',
    'voucher.encoding.usernameMinLength',
    'voucher.encoding.usernameMaxLength',
    'voucher.encoding.passwordMinLength',
    'voucher.encoding.passwordMaxLength',
    'voucher.encoding.excludeConfusingCharacters',
  ];

  final SettingsRepository _settingsRepository;

  Future<VoucherEncodingSettings> load() async {
    final values = <String, String?>{};
    for (final key in _keys) {
      values[key] = await _settingsRepository.readSetting(key);
    }
    return VoucherEncodingSettings.fromSettings(values);
  }

  Future<void> save(VoucherEncodingSettings settings) async {
    for (final entry in settings.toSettingsMap().entries) {
      await _settingsRepository.writeSetting(entry.key, entry.value);
    }
  }
}
