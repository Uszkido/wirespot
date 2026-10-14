import '../repositories/cloud_workspace_repository.dart';
import 'cloud_settings_service.dart';

/// Bridges local feature writes to the authenticated organization workspace.
/// A missing/expired cloud session is treated as offline, so local operations
/// remain usable and the normal sync queue can retry later.
class CloudWorkspaceSyncService {
  const CloudWorkspaceSyncService({
    required CloudWorkspaceRepository repository,
    required CloudSettingsService settingsService,
  }) : _repository = repository,
       _settingsService = settingsService;

  final CloudWorkspaceRepository _repository;
  final CloudSettingsService _settingsService;

  Future<bool> saveRouter({
    required String routerId,
    required Map<String, dynamic> routerData,
  }) async {
    final context = await _cloudContext();
    if (context == null) return false;
    return _repository.saveRouterDocument(
      idToken: context.$1,
      orgId: context.$2,
      routerId: routerId,
      routerData: routerData,
    );
  }

  Future<bool> saveVoucher({
    required String voucherId,
    required Map<String, dynamic> voucherData,
  }) async {
    final context = await _cloudContext();
    if (context == null) return false;
    return _repository.saveVoucherDocument(
      idToken: context.$1,
      orgId: context.$2,
      voucherId: voucherId,
      voucherData: voucherData,
    );
  }

  Future<(String, String)?> _cloudContext() async {
    final session = await _settingsService.loadSession();
    final connection = await _settingsService.loadConnection();
    final orgId = connection?.organizationId?.trim();
    if (session == null ||
        session.accessToken.isEmpty ||
        orgId == null ||
        orgId.isEmpty) {
      return null;
    }
    return (session.accessToken, orgId);
  }
}
