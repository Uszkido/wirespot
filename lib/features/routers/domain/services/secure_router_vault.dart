import '../../../../core/storage/secure_storage_service.dart';

class SecureRouterVault {
  const SecureRouterVault({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  static String _vaultKey({
    required String organizationId,
    required String routerId,
  }) {
    final safeOrg = organizationId.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final safeRouter = routerId.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    return 'router_secret_${safeOrg}_$safeRouter';
  }

  Future<void> storeRouterSecret({
    required String organizationId,
    required String routerId,
    required String secret,
  }) async {
    await _secureStorage.write(
      _vaultKey(organizationId: organizationId, routerId: routerId),
      secret,
    );
  }

  Future<String?> readRouterSecret({
    required String organizationId,
    required String routerId,
  }) async {
    return _secureStorage.read(
      _vaultKey(organizationId: organizationId, routerId: routerId),
    );
  }

  Future<void> deleteRouterSecret({
    required String organizationId,
    required String routerId,
  }) async {
    await _secureStorage.delete(
      _vaultKey(organizationId: organizationId, routerId: routerId),
    );
  }
}
