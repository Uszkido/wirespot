import 'package:flutter_test/flutter_test.dart';
import 'package:wirespot/features/cloud/domain/repositories/cloud_workspace_repository.dart';

class FakeCloudWorkspaceRepository implements CloudWorkspaceRepository {
  final Map<String, Map<String, dynamic>> routerDocs = {};
  final Map<String, Map<String, dynamic>> voucherDocs = {};
  final Map<String, Map<String, dynamic>> settingsDocs = {};

  @override
  Future<Map<String, dynamic>?> readRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
  }) async => routerDocs['$orgId/$routerId'];

  @override
  Future<bool> deleteRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
  }) async {
    return routerDocs.remove('$orgId/$routerId') != null;
  }

  @override
  Future<bool> saveRouterDocument({
    required String idToken,
    required String orgId,
    required String routerId,
    required Map<String, dynamic> routerData,
  }) async {
    routerDocs['$orgId/$routerId'] = routerData;
    return true;
  }

  @override
  Future<bool> saveVoucherDocument({
    required String idToken,
    required String orgId,
    required String voucherId,
    required Map<String, dynamic> voucherData,
  }) async {
    voucherDocs['$orgId/$voucherId'] = voucherData;
    return true;
  }

  @override
  Future<bool> saveSettingsDocument({
    required String idToken,
    required String orgId,
    required Map<String, dynamic> settingsData,
  }) async {
    settingsDocs[orgId] = settingsData;
    return true;
  }
}

void main() {
  group('CloudWorkspaceRepository', () {
    late FakeCloudWorkspaceRepository repo;

    setUp(() {
      repo = FakeCloudWorkspaceRepository();
    });

    test(
      'saveRouterDocument stores router payload under orgId/routerId',
      () async {
        final success = await repo.saveRouterDocument(
          idToken: 'token123',
          orgId: 'org_1',
          routerId: 'r-100',
          routerData: {'name': 'Main Router'},
        );

        expect(success, isTrue);
        expect(repo.routerDocs['org_1/r-100'], {'name': 'Main Router'});
      },
    );

    test(
      'saveVoucherDocument stores voucher payload under orgId/voucherId',
      () async {
        final success = await repo.saveVoucherDocument(
          idToken: 'token123',
          orgId: 'org_1',
          voucherId: 'v-200',
          voucherData: {'code': 'WS-100'},
        );

        expect(success, isTrue);
        expect(repo.voucherDocs['org_1/v-200'], {'code': 'WS-100'});
      },
    );

    test('saveSettingsDocument stores settings payload under orgId', () async {
      final success = await repo.saveSettingsDocument(
        idToken: 'token123',
        orgId: 'org_1',
        settingsData: {'currency': 'NGN'},
      );

      expect(success, isTrue);
      expect(repo.settingsDocs['org_1'], {'currency': 'NGN'});
    });
  });
}
