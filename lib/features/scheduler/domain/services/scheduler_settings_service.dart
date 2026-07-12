import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/scheduled_task.dart';

class SchedulerSettingsService {
  const SchedulerSettingsService(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  Future<List<ScheduledTask>> load() async {
    final tasks = <ScheduledTask>[];
    for (final task in ScheduledTask.defaults()) {
      final enabled = await _settingsRepository.readSetting(
        _enabledKey(task.type),
      );
      final interval = await _settingsRepository.readSetting(
        _intervalKey(task.type),
      );
      tasks.add(
        task.copyWith(
          enabled: enabled == 'true',
          intervalMinutes: int.tryParse(interval ?? '') ?? task.intervalMinutes,
        ),
      );
    }
    return tasks;
  }

  Future<void> save(ScheduledTask task) async {
    await _settingsRepository.writeSetting(
      _enabledKey(task.type),
      task.enabled ? 'true' : 'false',
    );
    await _settingsRepository.writeSetting(
      _intervalKey(task.type),
      '${task.intervalMinutes}',
    );
  }

  String _enabledKey(ScheduledTaskType type) {
    return 'scheduler.${type.name}.enabled';
  }

  String _intervalKey(ScheduledTaskType type) {
    return 'scheduler.${type.name}.intervalMinutes';
  }
}
