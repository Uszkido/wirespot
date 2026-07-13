import 'dart:convert';

import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/ticket_template.dart';

class TicketTemplateSettingsService {
  const TicketTemplateSettingsService(this._repository);

  static const _selectedTemplateKey = 'voucher.ticket_template.selected';
  static const _customTemplateKey = 'voucher.ticket_template.custom';

  final SettingsRepository _repository;

  Future<TicketTemplate> loadSelected() async {
    final id = await _repository.readSetting(_selectedTemplateKey);
    final selected = TicketTemplate.byId(id);
    final customJson = await _repository.readSetting(_customTemplateKey);
    if (customJson == null || customJson.isEmpty) {
      return selected;
    }

    try {
      final decoded = jsonDecode(customJson);
      if (decoded is! Map) {
        return selected;
      }
      final custom = TicketTemplate.fromJson(
        Map<String, Object?>.from(decoded),
      );
      return custom.id == selected.id ? custom : selected;
    } on Object {
      return selected;
    }
  }

  Future<void> saveSelected(TicketTemplate template) {
    return _repository.writeSetting(_selectedTemplateKey, template.id);
  }

  Future<void> saveCustom(TicketTemplate template) async {
    await _repository.writeSetting(_selectedTemplateKey, template.id);
    await _repository.writeSetting(
      _customTemplateKey,
      jsonEncode(template.toJson()),
    );
  }
}
