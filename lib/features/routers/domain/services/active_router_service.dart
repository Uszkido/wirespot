import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/repositories/settings_repository.dart';

class ActiveRouterService {
  const ActiveRouterService(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<String?> loadSelectedRouterId() {
    return _settingsRepository.readSetting(AppSettingsKeys.activeRouterId);
  }

  Future<void> selectRouter(String routerId) {
    return _settingsRepository.writeSetting(
      AppSettingsKeys.activeRouterId,
      routerId,
    );
  }
}
