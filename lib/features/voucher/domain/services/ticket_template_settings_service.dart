import '../../../settings/domain/repositories/settings_repository.dart';
import '../entities/ticket_template.dart';

class TicketTemplateSettingsService {
  const TicketTemplateSettingsService(this._repository);

  static const _selectedTemplateKey = 'voucher.ticket_template.selected';

  final SettingsRepository _repository;

  Future<TicketTemplate> loadSelected() async {
    final id = await _repository.readSetting(_selectedTemplateKey);
    return TicketTemplate.byId(id);
  }

  Future<void> saveSelected(TicketTemplate template) {
    return _repository.writeSetting(_selectedTemplateKey, template.id);
  }
}
