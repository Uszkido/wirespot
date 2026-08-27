import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/core/storage/secure_storage_service.dart';
import 'package:wirespot/features/routers/domain/services/secure_router_vault.dart';

class FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> write(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(_store);
}

void main() {
  group('SecureRouterVault', () {
    late FakeSecureStorageService fakeStorage;
    late SecureRouterVault vault;

    setUp(() {
      fakeStorage = FakeSecureStorageService();
      vault = SecureRouterVault(secureStorage: fakeStorage);
    });

    test('stores and reads router password securely', () async {
      await vault.storeRouterSecret(routerId: 'r-1', secret: 'superSecret123');
      final secret = await vault.readRouterSecret('r-1');

      expect(secret, equals('superSecret123'));
    });

    test('deletes router password securely', () async {
      await vault.storeRouterSecret(routerId: 'r-1', secret: 'superSecret123');
      await vault.deleteRouterSecret('r-1');
      final secret = await vault.readRouterSecret('r-1');

      expect(secret, isNull);
    });
  });
}
