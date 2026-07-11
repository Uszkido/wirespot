import 'secure_storage_keys.dart';
import 'secure_storage_service.dart';

class VoucherSecretStore {
  const VoucherSecretStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<String?> readPassword(String voucherId) {
    return _secureStorage.read(SecureStorageKeys.voucherPassword(voucherId));
  }

  Future<void> writePassword(String voucherId, String password) {
    return _secureStorage.write(
      SecureStorageKeys.voucherPassword(voucherId),
      password,
    );
  }

  Future<void> deletePassword(String voucherId) {
    return _secureStorage.delete(SecureStorageKeys.voucherPassword(voucherId));
  }
}
