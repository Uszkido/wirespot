import 'dart:convert';

import '../../../../core/storage/secure_storage_keys.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../entities/cloud_connection_settings.dart';
import '../entities/cloud_session.dart';

class CloudSettingsService {
  const CloudSettingsService(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<CloudConnectionSettings?> loadConnection() async {
    final value = await _secureStorage.read(
      SecureStorageKeys.cloudConnectionSettings,
    );
    if (value == null) return null;
    return CloudConnectionSettings.fromJson(
      jsonDecode(value) as Map<String, Object?>,
    );
  }

  Future<void> saveConnection(CloudConnectionSettings settings) async {
    settings.apiBaseUri;
    await _secureStorage.write(
      SecureStorageKeys.cloudConnectionSettings,
      jsonEncode(settings.toJson()),
    );
  }

  Future<CloudSession?> loadSession() async {
    final value = await _secureStorage.read(SecureStorageKeys.cloudSession);
    if (value == null) return null;
    final session = CloudSession.fromJson(
      jsonDecode(value) as Map<String, Object?>,
    );
    if (session.isExpired) {
      await clearSession();
      return null;
    }
    return session;
  }

  Future<void> saveSession(CloudSession session) => _secureStorage.write(
    SecureStorageKeys.cloudSession,
    jsonEncode(session.toJson()),
  );

  Future<void> clearSession() =>
      _secureStorage.delete(SecureStorageKeys.cloudSession);
}
