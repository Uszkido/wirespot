import 'package:dio/dio.dart';

import '../domain/services/cloud_settings_service.dart';

class CloudApiClient {
  const CloudApiClient({
    required Dio dio,
    required CloudSettingsService settingsService,
  }) : _dio = dio,
       _settingsService = settingsService;

  final Dio _dio;
  final CloudSettingsService _settingsService;

  Future<Response<Map<String, dynamic>>> getJson(String path) {
    return _request('GET', path);
  }

  Future<Response<Map<String, dynamic>>> postJson(
    String path, {
    Map<String, Object?> data = const {},
    String? idempotencyKey,
  }) => _request('POST', path, data: data, idempotencyKey: idempotencyKey);

  Future<bool> testConnection() async {
    try {
      final response = await getJson('health');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> pairDevice(String pairingKey) async {
    final response = await _request(
      'POST',
      'auth/pair',
      data: {'pairingKey': pairingKey},
      requireSession: false,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _request(
      'POST',
      'auth/login',
      data: {'email': email, 'password': password},
      requireSession: false,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String organizationName,
  }) async {
    final response = await _request(
      'POST',
      'auth/register',
      data: {
        'email': email,
        'password': password,
        'organizationName': organizationName,
      },
      requireSession: false,
    );
    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> fetchPendingCommands() async {
    final response = await getJson('commands/pending');
    final data = response.data?['commands'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<bool> acknowledgeCommand({
    required String commandId,
    required String status,
    Map<String, Object?>? resultPayload,
    String? errorMessage,
  }) async {
    final response = await postJson(
      'commands/$commandId/ack',
      data: {
        'status': status,
        if (resultPayload != null) 'resultPayload': resultPayload,
        if (errorMessage != null) 'errorMessage': errorMessage,
        'executedAt': DateTime.now().toIso8601String(),
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> postTelemetry(Map<String, Object?> telemetryData) async {
    final response = await postJson('telemetry', data: telemetryData);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> uploadCloudBackup(Map<String, Object?> payloadJson) async {
    final response = await postJson('backup/upload', data: payloadJson);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<Map<String, dynamic>?> fetchLatestCloudBackup() async {
    try {
      final response = await getJson('backup/latest');
      if (response.statusCode == 200 && response.data != null) {
        final backupData = response.data?['backup'] ?? response.data;
        if (backupData is Map) {
          return Map<String, dynamic>.from(backupData);
        }
      }
    } catch (_) {
      // Cloud backup may not exist yet or connection offline
    }
    return null;
  }

  Future<Response<Map<String, dynamic>>> _request(
    String method,
    String path, {
    Map<String, Object?>? data,
    String? idempotencyKey,
    bool requireSession = true,
  }) async {
    final settings = await _settingsService.loadConnection();
    final session = await _settingsService.loadSession();
    if (settings == null) {
      throw StateError('Configure a WireSpot Cloud API connection first.');
    }
    if (requireSession && (session == null || session.accessToken.isEmpty)) {
      throw StateError('Connect to WireSpot Cloud and sign in before syncing.');
    }
    final headers = <String, String>{
      if (session != null && session.accessToken.isNotEmpty)
        'Authorization': 'Bearer ${session.accessToken}',
      if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
    };
    final organizationId = settings.organizationId?.trim();
    if (organizationId != null && organizationId.isNotEmpty) {
      headers['X-WireSpot-Organization'] = organizationId;
    }
    final response = await _dio.request<Map<String, dynamic>>(
      settings.apiBaseUri
          .resolve(path.replaceFirst(RegExp(r'^/'), ''))
          .toString(),
      data: data,
      options: Options(method: method, headers: headers),
    );
    return response;
  }
}
