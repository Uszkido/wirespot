import 'dart:convert';

import 'router_credentials.dart';
import 'secure_storage_keys.dart';
import 'secure_storage_service.dart';

class RouterCredentialStore {
  const RouterCredentialStore(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<String?> _organizationId() async {
    final encoded = await _secureStorage.read(
      SecureStorageKeys.cloudConnectionSettings,
    );
    if (encoded == null) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map) return decoded['organizationId']?.toString();
    } on Object {
      // Treat malformed connection settings as an unscoped local workspace.
    }
    return null;
  }

  Future<RouterCredentials?> read(String routerId) async {
    final organizationId = await _organizationId();
    final encoded =
        await _secureStorage.read(
          SecureStorageKeys.routerCredentials(
            routerId,
            organizationId: organizationId,
          ),
        ) ??
        await _secureStorage.read('router.$routerId.credentials');
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
    return _writeScoped(routerId, credentials);
  }

  Future<void> _writeScoped(
    String routerId,
    RouterCredentials credentials,
  ) async {
    final organizationId = await _organizationId();
    await _secureStorage.write(
      SecureStorageKeys.routerCredentials(
        routerId,
        organizationId: organizationId,
      ),
      jsonEncode(credentials.toJson()),
    );
  }

  Future<void> delete(String routerId) async {
    final organizationId = await _organizationId();
    await _secureStorage.delete(
      SecureStorageKeys.routerCredentials(
        routerId,
        organizationId: organizationId,
      ),
    );
    // Remove the pre-scoping key as well when upgrading an existing install.
    await _secureStorage.delete('router.$routerId.credentials');
  }
}
