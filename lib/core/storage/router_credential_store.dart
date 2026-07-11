import 'dart:convert';

import 'router_credentials.dart';
import 'secure_storage_keys.dart';
import 'secure_storage_service.dart';

class RouterCredentialStore {
  const RouterCredentialStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<RouterCredentials?> read(String routerId) async {
    final encoded = await _secureStorage.read(
      SecureStorageKeys.routerCredentials(routerId),
    );
    if (encoded == null) {
      return null;
    }

    final decoded = jsonDecode(encoded);
    if (decoded is! Map<String, Object?>) {
      return null;
    }

    return RouterCredentials.fromJson(decoded);
  }

  Future<void> write(String routerId, RouterCredentials credentials) {
    return _secureStorage.write(
      SecureStorageKeys.routerCredentials(routerId),
      jsonEncode(credentials.toJson()),
    );
  }

  Future<void> delete(String routerId) {
    return _secureStorage.delete(SecureStorageKeys.routerCredentials(routerId));
  }
}
