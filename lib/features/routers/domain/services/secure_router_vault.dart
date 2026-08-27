import '../../../../core/storage/secure_storage_service.dart';

class SecureRouterVault {
  const SecureRouterVault({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage;

  final SecureStorageService _secureStorage;

  static String _vaultKey(String routerId) => 'router_secret_$routerId';

  Future<void> storeRouterSecret({
    required String routerId,
    required String secret,
  }) async {
    await _secureStorage.write(_vaultKey(routerId), secret);
  }

  Future<String?> readRouterSecret(String routerId) async {
    return _secureStorage.read(_vaultKey(routerId));
  }

  Future<void> deleteRouterSecret(String routerId) async {
    await _secureStorage.delete(_vaultKey(routerId));
  }
}
