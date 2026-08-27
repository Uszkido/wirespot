import '../../data/firebase_api_client.dart';

abstract class CloudWorkspaceRepository {
  Future<Map<String, dynamic>?> readRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
  }) => throw UnimplementedError();

  Future<bool> saveRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
    required Map<String, dynamic> routerData,
  });

  Future<bool> saveVoucherDocument({
    required String idToken,
    required String orgId,
    required String voucherId,
    required Map<String, dynamic> voucherData,
  });

  Future<bool> saveSettingsDocument({
    required String idToken,
    required String orgId,
    required Map<String, dynamic> settingsData,
  });

  Future<bool> deleteRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
  }) => throw UnimplementedError();
}

class FirebaseCloudWorkspaceRepository implements CloudWorkspaceRepository {
  FirebaseCloudWorkspaceRepository({FirebaseApiClient? apiClient})
    : _apiClient = apiClient ?? FirebaseApiClient();

  final FirebaseApiClient _apiClient;

  @override
  Future<Map<String, dynamic>?> readRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
  }) {
    return _apiClient.getFirestoreDocument(
      idToken: idToken,
      documentPath: 'organizations/$orgId/routers/$routerId',
    );
  }

  @override
  Future<bool> saveRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
    required Map<String, dynamic> routerData,
  }) {
    return _apiClient.setFirestoreDocument(
      idToken: idToken,
      documentPath: 'organizations/$orgId/routers/$routerId',
      fields: routerData,
    );
  }

  @override
  Future<bool> saveVoucherDocument({
    required String idToken,
    required String orgId,
    required String voucherId,
    required Map<String, dynamic> voucherData,
  }) {
    return _apiClient.setFirestoreDocument(
      idToken: idToken,
      documentPath: 'organizations/$orgId/vouchers/$voucherId',
      fields: voucherData,
    );
  }

  @override
  Future<bool> saveSettingsDocument({
    required String idToken,
    required String orgId,
    required Map<String, dynamic> settingsData,
  }) {
    return _apiClient.setFirestoreDocument(
      idToken: idToken,
      documentPath: 'organizations/$orgId/settings/config',
      fields: settingsData,
    );
  }

  @override
  Future<bool> deleteRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
  }) {
    return _apiClient.deleteFirestoreDocument(
      idToken: idToken,
      documentPath: 'organizations/$orgId/routers/$routerId',
    );
  }
}
