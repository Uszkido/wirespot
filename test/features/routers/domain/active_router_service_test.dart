import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/routers/domain/services/active_router_service.dart';
import 'package:wirespot/features/settings/domain/entities/printer_config_entity.dart';
import 'package:wirespot/features/settings/domain/repositories/settings_repository.dart';

void main() {
  test('persists and reads the selected router id', () async {
    final repository = _MemorySettingsRepository();
    final service = ActiveRouterService(repository);

    await service.selectRouter('router-2');

    expect(await service.loadSelectedRouterId(), 'router-2');
  });

  test('clears the selected router id', () async {
    final repository = _MemorySettingsRepository();
    final service = ActiveRouterService(repository);
    await service.selectRouter('router-2');

    await service.clearSelectedRouter();

    expect(await service.loadSelectedRouterId(), isNull);
  });
}

class _MemorySettingsRepository implements SettingsRepository {
  final _settings = <String, String>{};

  @override
  Future<void> deletePrinter(String id) async {}

  @override
  Future<List<PrinterConfigEntity>> getPrinters() async => const [];

  @override
  Future<String?> readSetting(String key) async => _settings[key];

  @override
  Future<void> savePrinter(PrinterConfigEntity printer) async {}

  @override
  Future<void> writeSetting(String key, String value) async {
    _settings[key] = value;
  }
}
