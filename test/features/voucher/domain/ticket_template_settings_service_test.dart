import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/settings/domain/entities/printer_config_entity.dart';
import 'package:wirespot/features/settings/domain/repositories/settings_repository.dart';
import 'package:wirespot/features/voucher/domain/entities/ticket_template.dart';
import 'package:wirespot/features/voucher/domain/services/ticket_template_settings_service.dart';

void main() {
  test('round-trips custom ticket template settings', () async {
    final repository = _FakeSettingsRepository();
    final service = TicketTemplateSettingsService(repository);

    final custom = TicketTemplate.defaults.first.copyWith(
      name: 'Field Ticket',
      paperWidthMm: 80,
      showLogo: false,
      showQrCode: false,
      showPrice: false,
      footer: 'Thank you',
    );

    await service.saveCustom(custom);
    final loaded = await service.loadSelected();

    expect(loaded.name, 'Field Ticket');
    expect(loaded.paperWidthMm, 80);
    expect(loaded.showLogo, isFalse);
    expect(loaded.showQrCode, isFalse);
    expect(loaded.showPrice, isFalse);
    expect(loaded.footer, 'Thank you');
  });

  test('falls back to preset when stored custom template is invalid', () async {
    final repository = _FakeSettingsRepository()
      ..values['voucher.ticket_template.selected'] = 'thermal_80'
      ..values['voucher.ticket_template.custom'] = 'not-json';
    final service = TicketTemplateSettingsService(repository);

    final loaded = await service.loadSelected();

    expect(loaded, TicketTemplate.byId('thermal_80'));
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  final values = <String, String>{};

  @override
  Future<String?> readSetting(String key) async => values[key];

  @override
  Future<void> writeSetting(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> deletePrinter(String id) {
    throw UnimplementedError();
  }

  @override
  Future<List<PrinterConfigEntity>> getPrinters() {
    throw UnimplementedError();
  }

  @override
  Future<void> savePrinter(PrinterConfigEntity printer) {
    throw UnimplementedError();
  }
}
